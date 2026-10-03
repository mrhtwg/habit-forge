// Recomputes the cached balances from the ledger and reports every mismatch.
//
// This is T5 of `docs/data-ledger-plan.md` §9 and the acceptance tool of §7.3:
//
//   opening_balance + Σ events == cached balance   (gold, gems, HP exactly;
//                                                   EXP via the level curve)
//
// Usage (from `app/`):
//
//   dart run tool/reconcile_ledger.dart export.json
//   dart run tool/reconcile_ledger.dart --rest http://127.0.0.1:8080 \
//       --project demo-habitforge --uid THE_UID
//
// `export.json` is either the plain shape
//
//   {"user": { ...user document... }, "events": [ { ...row... }, ... ]}
//
// or a raw Firestore REST payload (a document with `fields`, and either a
// `documents` list or a list of `{"document": ...}` entries) — both are
// unwrapped automatically, so a Console/CLI export can be piped in as-is.
//
// Exit code: 0 when balanced, 1 on any mismatch or structural problem.
//
// Note: `--rest` sends `Authorization: Bearer owner`, which the *emulator*
// accepts as admin. A production project needs a real token, so use a file
// export there.

import 'dart:convert';
import 'dart:io';

import 'package:habit_forge_app/core/network/ledger/ledger_reconcile.dart';

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  if (options == null) {
    stderr.writeln(_usage);
    exit(2);
  }

  final Map<String, Object?> payload;
  try {
    payload = await (options.rest == null ? _readFile(options.file!) : _readRest(options));
  } catch (e) {
    stderr.writeln('could not read the ledger: $e');
    exit(2);
  }

  final user = _asMap(_unwrap(payload['user'] ?? payload));
  final prefs = _asMap(_unwrap(_asMap(user['prefs'])));
  final character = _asMap(_unwrap(_asMap(user['character'])));

  final cached = CachedBalance(
    // proto3 JSON spells int64 fields in lowerCamelCase; accept snake_case too
    // so hand-written exports and the plan's §6.1 sketch both work.
    gold: asInt(prefs['currentGold'] ?? prefs['current_gold']),
    gems: asInt(prefs['currentGems'] ?? prefs['current_gems']),
    hp: asInt(character['currentHp'] ?? character['current_hp']),
    exp: asInt(character['currentExp'] ?? character['current_exp']),
    level: asInt(character['level']),
  );

  final seq = user['ledgerSeq'];
  final audit = auditLedger(
    events: _eventDocs(payload),
    cached: cached,
    ledgerSeq: seq == null ? null : asInt(seq),
  );

  stdout.write(audit.describe());
  exit(audit.balanced ? 0 : 1);
}

const String _usage = '''
usage: dart run tool/reconcile_ledger.dart <export.json>
       dart run tool/reconcile_ledger.dart --rest <baseUrl> --project <id> --uid <uid> [--database "(default)"]''';

/// Ledger rows out of either input shape (plain JSON list, REST `documents`
/// list, or a list of REST `{"document": …}` entries).
List<Object?> _eventDocs(Map<String, Object?> payload) {
  final raw = payload['events'] ?? payload['documents'] ?? const <Object?>[];
  if (raw is! List) return const <Object?>[];
  return raw.map((entry) {
    final item = _asMap(entry);
    final document = item['document'];
    if (document != null) return _unwrap(document);
    if (item.containsKey('fields')) return _unwrap(item);
    return item;
  }).toList();
}

Future<Map<String, Object?>> _readFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) throw StateError('no such file: $path');
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) throw StateError('expected a JSON object at the top level');
  return _asMap(decoded);
}

Future<Map<String, Object?>> _readRest(_Options options) async {
  final base = options.rest!.replaceAll(RegExp(r'/+$'), '');
  final db = Uri.encodeComponent(options.database);
  final root = '$base/v1/projects/${options.project}/databases/$db/documents/users/${options.uid}';
  return <String, Object?>{
    'user': _unwrap(await _getJson(root)),
    'events': await _getAllPages('$root/events'),
  };
}

Future<List<Object?>> _getAllPages(String url) async {
  final out = <Object?>[];
  String? pageToken;
  do {
    final separator = url.contains('?') ? '&' : '?';
    final body = _asMap(await _getJson('$url${separator}pageSize=300${pageToken == null ? '' : '&pageToken=$pageToken'}'));
    final documents = body['documents'];
    if (documents is List) out.addAll(documents);
    pageToken = body['nextPageToken'] as String?;
  } while (pageToken != null && pageToken.isNotEmpty);
  return out;
}

Future<Object?> _getJson(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    // The emulator treats `owner` as admin; a production project needs an OAuth
    // token, which is why the file export is the documented path for prod.
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw StateError('GET $url -> ${response.statusCode}: $body');
    }
    return jsonDecode(body);
  } finally {
    client.close(force: true);
  }
}

Object? _unwrap(Object? raw) {
  final map = _asMap(raw);
  if (map.containsKey('fields')) return unwrapFirestoreFields(map['fields']);
  return raw is Map ? unwrapFirestoreFields(raw) : raw;
}

Map<String, Object?> _asMap(Object? raw) {
  if (raw is Map) return {for (final e in raw.entries) '${e.key}': e.value};
  return <String, Object?>{};
}

class _Options {
  _Options({this.file, this.rest, this.project = '', this.uid = '', this.database = '(default)'});

  final String? file;
  final String? rest;
  final String project;
  final String uid;
  final String database;

  static _Options? parse(List<String> args) {
    String? file;
    String? rest;
    var project = '';
    var uid = '';
    var database = '(default)';
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String next() => i + 1 < args.length ? args[++i] : '';
      switch (arg) {
        case '--rest':
          rest = next();
        case '--project':
          project = next();
        case '--uid':
          uid = next();
        case '--database':
          database = next();
        default:
          if (arg.startsWith('--')) return null;
          file = arg;
      }
    }
    if (rest == null) {
      if (file == null) return null;
      return _Options(file: file);
    }
    if (project.isEmpty || uid.isEmpty) return null;
    return _Options(rest: rest, project: project, uid: uid, database: database);
  }
}
