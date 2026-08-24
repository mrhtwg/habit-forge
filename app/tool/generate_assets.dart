// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent;

  // Only scan the app's own assets/ directory and generate lib/generated/assets.dart -> Assets class
  final assetsDir = Directory('${projectRoot.path}/assets');
  final outputFile = File('${projectRoot.path}/lib/generated/assets.dart');

  if (!assetsDir.existsSync()) {
    print('⚠️  assets directory does not exist, skipping: ${assetsDir.path}');
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
      print('🗑️  Removed stale output file: ${outputFile.path}');
    }
    print('🎉 Done - nothing to generate!');
    return;
  }

  print('🚀 Generating assets.dart...');
  final assets = await _scanAndCollect(assetsDir, projectRoot);
  _writeAssetsFile(assets, outputFile, 'Assets', projectRoot);
  print('✅ Generated ${assets.length} assets into ${outputFile.path}');
  print('🎉 assets.dart generation finished!');
}

/// Directories to exclude from the generated output (relative to the app project root).
///
/// Append new directories here to exclude them as well, e.g.:
///   'assets/animations/archer_idle',
const _excludeAssetDirs = [
  'assets/animations/knight_idle',
  'assets/animations/mage_idle',
  'assets/animations/ranger_idle',
];

/// Returns true if the relative path matches one of the configured exclude directories
bool _isExcluded(String relativePath) {
  for (final dir in _excludeAssetDirs) {
    if (relativePath == dir || relativePath.startsWith('$dir/')) {
      return true;
    }
  }
  return false;
}

/// Converts a file path to a variable name
String _pathToVariableName(String path) {
  // Strip the 'assets/' prefix
  if (path.startsWith('assets/')) {
    path = path.substring('assets/'.length);
  }

  // Strip the file extension (everything after the first dot)
  // This correctly handles special file names like .9.json
  final lastSlash = path.lastIndexOf('/');
  final fileName = lastSlash == -1 ? path : path.substring(lastSlash + 1);
  final firstDot = fileName.indexOf('.');

  if (firstDot != -1) {
    // Has an extension: remove the first dot and everything after it
    final pathWithoutFile = lastSlash == -1 ? '' : path.substring(0, lastSlash + 1);
    final fileNameWithoutExt = fileName.substring(0, firstDot);
    path = pathWithoutFile + fileNameWithoutExt;
  }

  // Split by '/'
  final segments = path.split('/');

  // Convert each segment to camel case
  final camelSegments = <String>[];
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    final camelSegment = _toCamelCase(segment, isFirst: i == 0);
    camelSegments.add(camelSegment);
  }

  return camelSegments.join('');
}

/// Scans the directory and collects asset files (excluding folders in [_excludeAssetDirs])
Future<Map<String, String>> _scanAndCollect(Directory assetsDir, Directory projectRoot) async {
  final assetFiles = <FileSystemEntity>[];
  await _scanDirectory(assetsDir, assetFiles);

  final assets = <String, String>{};
  final duplicates = <String, List<String>>{};
  var excludedCount = 0;

  for (final file in assetFiles) {
    if (file is File) {
      var relativePath = file.path.replaceAll('${projectRoot.path}/', '').replaceAll('\\', '/');
      // Skip files inside the configured exclude directories
      if (_isExcluded(relativePath)) {
        excludedCount++;
        continue;
      }
      // Variable name is based on the path relative to assets/
      final variableName = _pathToVariableName(relativePath);

      if (assets.containsKey(variableName)) {
        if (!duplicates.containsKey(variableName)) {
          duplicates[variableName] = [assets[variableName]!];
        }
        duplicates[variableName]!.add(relativePath);
      } else {
        assets[variableName] = relativePath;
      }
    }
  }

  if (excludedCount > 0) {
    print('🚫 Excluded $excludedCount files under $_excludeAssetDirs');
  }

  if (duplicates.isNotEmpty) {
    print('');
    print('❌ ERROR: Duplicate file names detected!');
    print('');
    for (final entry in duplicates.entries) {
      print('🔴 Variable name conflict: ${entry.key}');
      for (final file in entry.value) {
        print('   - $file');
      }
      print('');
    }
    print('💡 How to fix:');
    print('   1. Rename one of the files so the file names differ');
    print('   2. Move the file to a different directory');
    print('   3. Delete the unneeded duplicate file');
    print('');
    exit(1);
  }

  return assets;
}

/// Recursively scans a directory
Future<void> _scanDirectory(Directory dir, List<FileSystemEntity> files) async {
  try {
    await for (var entity in dir.list()) {
      // Skip hidden files and .DS_Store
      final name = entity.path.split('/').last;
      if (name.startsWith('.')) continue;

      if (entity is Directory) {
        await _scanDirectory(entity, files);
      } else if (entity is File) {
        files.add(entity);
      }
    }
  } catch (e) {
    print('⚠️  Failed to scan directory: ${dir.path} - $e');
  }
}

/// Converts an underscore/hyphen separated string to camel case
String _toCamelCase(String str, {required bool isFirst}) {
  if (str.isEmpty) return str;

  // Normalize hyphens and dots to underscores
  str = str.replaceAll('-', '_').replaceAll('.', '_');

  // Split by underscore
  final parts = str.split('_');
  final buffer = StringBuffer();

  for (var i = 0; i < parts.length; i++) {
    var part = parts[i];
    if (part.isEmpty) continue;

    // First word handling
    if (i == 0 && isFirst) {
      // First word of the first segment: lowercase first letter
      buffer.write(part[0].toLowerCase());
      if (part.length > 1) {
        buffer.write(part.substring(1));
      }
    } else {
      // Other words: uppercase first letter
      buffer.write(part[0].toUpperCase());
      if (part.length > 1) {
        buffer.write(part.substring(1));
      }
    }
  }

  return buffer.toString();
}

/// Writes the assets.dart file
void _writeAssetsFile(Map<String, String> assets, File outputFile, String className, Directory projectRoot) {
  final sortedKeys = assets.keys.toList()..sort();

  final buffer = StringBuffer();
  buffer.writeln('// ignore_for_file: prefer_single_quotes');
  buffer.writeln();
  buffer.writeln('class $className {');
  buffer.writeln('  ${className}._();');
  buffer.writeln();

  for (final key in sortedKeys) {
    final path = assets[key]!;
    buffer.writeln('  static const String $key = "$path";');
    buffer.writeln();
  }

  buffer.writeln('}');

  // Collect font files
  final fonts = <String>[];
  for (final path in assets.values) {
    if (path.startsWith('assets/fonts/') && path.endsWith('.ttf')) {
      final fileName = path.split('/').last;
      final fontName = fileName.substring(0, fileName.lastIndexOf('.'));
      fonts.add(fontName);
    }
  }

  if (fonts.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('class FontFamily {');
    buffer.writeln('  FontFamily._();');
    buffer.writeln();

    for (final fontName in fonts) {
      final variableName = _toCamelCase(fontName, isFirst: true);
      buffer.writeln('  /// Font family: $fontName');
      buffer.writeln('  static const String $variableName = \'$fontName\';');
      buffer.writeln();
    }

    buffer.writeln('}');
  }

  if (!outputFile.parent.existsSync()) {
    outputFile.parent.createSync(recursive: true);
  }

  outputFile.writeAsStringSync(buffer.toString());

  // Format the output (with FVM fallback)
  final formatResult =
      Process.runSync('dart', ['format', '--line-length=200', outputFile.path], workingDirectory: projectRoot.path);
  if (formatResult.exitCode == 0) {
    print('🎨 Code formatting done: ${outputFile.path}');
  } else {
    final fvmResult = Process.runSync(
      'fvm',
      ['dart', 'format', '--line-length=200', outputFile.path],
      workingDirectory: projectRoot.path,
    );
    if (fvmResult.exitCode == 0) {
      print('🎨 Code formatting done (fvm): ${outputFile.path}');
    } else {
      print('⚠️  Formatting warning: ${formatResult.stderr}');
    }
  }
}
