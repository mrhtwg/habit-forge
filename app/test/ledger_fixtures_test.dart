import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/emit_ledger_fixtures.dart';

/// The Firestore rules mirror the caps and payload shape of
/// `ledger_event.dart`, and the emulator test proves the rules accept what the
/// app writes — but only if the committed fixtures are still what the app
/// writes. This guard keeps the two languages honest without needing an
/// emulator: `flutter test` fails the moment a row shape changes.
///
/// Fix a failure with:
///   dart run tool/emit_ledger_fixtures.dart
void main() {
  test('the committed emulator fixtures match what the app writes', () {
    final file = File(defaultFixturePath);
    expect(file.existsSync(), isTrue, reason: 'run: dart run tool/emit_ledger_fixtures.dart');
    expect(
      file.readAsStringSync(),
      encodeLedgerFixtures(),
      reason: 'fixtures drifted from GameLedger — run: dart run tool/emit_ledger_fixtures.dart',
    );
  });
}
