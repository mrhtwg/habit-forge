import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logger built on the `logger` package (adapted from the tata
/// project).
///
/// Usage:
/// ```dart
/// // In main.dart, once:
/// Log.init(isLogEnabled: kDebugMode);
///
/// Log.d('debug message');
/// Log.i('info message');
/// Log.w('warning message');
/// Log.e('error message', error: exception);
/// Log.tag('Network').d('request succeeded');
/// ```
class Log {
  static Logger? _logger;
  static bool _isLogEnabled = true;
  static bool _isInitialized = false;

  // Private constructor to prevent instantiation.
  Log._();

  /// Debug log.
  static void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.d(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Database log (convenience).
  static void database(String message, {Object? error, StackTrace? stackTrace}) {
    d('[DATABASE] $message', error: error, stackTrace: stackTrace);
  }

  /// Error log.
  static void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.e(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Fatal log.
  static void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.f(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Info log.
  static void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.i(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Initializes the logger.
  ///
  /// [isLogEnabled] — whether logging is enabled; defaults to [kDebugMode]
  /// so logs are only printed in debug builds.
  /// [logLevel] — minimum level to print, defaults to [Level.trace].
  /// [methodCount] — number of caller frames shown, defaults to 0.
  /// [errorMethodCount] — number of stack frames shown on errors, defaults to 5.
  /// [printEmojis] — whether to prefix entries with emojis, defaults to true.
  /// [printTime] — whether to print timestamps, defaults to true.
  static void init({
    bool? isLogEnabled,
    Level logLevel = Level.trace,
    int methodCount = 0,
    int errorMethodCount = 5,
    bool printEmojis = true,
    bool printTime = true,
  }) {
    _isLogEnabled = isLogEnabled ?? kDebugMode;
    _isInitialized = true;

    if (!_isLogEnabled) {
      _logger = Logger(level: Level.off, printer: PrettyPrinter());
      return;
    }

    _logger = Logger(
      level: logLevel,
      printer: PrettyPrinter(
        methodCount: methodCount,
        errorMethodCount: errorMethodCount,
        lineLength: 100,
        colors: true,
        printEmojis: printEmojis,
        dateTimeFormat: printTime ? DateTimeFormat.onlyTimeAndSinceStart : DateTimeFormat.none,
      ),
    );
  }

  /// Navigation log (convenience).
  static void navigation(String message) {
    d('[NAVIGATION] $message');
  }

  /// Network log (convenience).
  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    d('[NETWORK] $message', error: error, stackTrace: stackTrace);
  }

  /// Performance log (convenience).
  static void performance(String message) {
    i('[PERFORMANCE] $message');
  }

  /// Trace log (most detailed).
  static void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.t(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Returns a logger that prefixes every message with [tag].
  ///
  /// Example: `Log.tag('Network').d('request succeeded')`.
  static TaggedLogger tag(String tag) {
    return TaggedLogger(tag);
  }

  /// Warning log.
  static void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _ensureInitialized();
    if (_isLogEnabled && _logger != null) {
      _logger!.w(message, time: time, error: error, stackTrace: stackTrace);
    }
  }

  /// Lazily initializes with defaults on first use.
  static void _ensureInitialized() {
    if (!_isInitialized) {
      init();
    }
  }
}

/// A logger bound to a tag prefix.
class TaggedLogger {
  final String tag;

  TaggedLogger(this.tag);

  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.d('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.e('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }

  void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.f('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.i('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }

  void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.t('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.w('[$tag] $message', time: time, error: error, stackTrace: stackTrace);
  }
}
