import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/achievement_unlock_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

/// Owns the death → recovery → revive loop.
///
/// A dead hero cannot complete tasks (the storage layer refuses it), so
/// something has to watch `deathRecoveryUntil` and revive the character once the
/// countdown elapses — including while the app is backgrounded, or after it was
/// killed and relaunched. This service is that owner: it keeps a 1-second ticker
/// alive only while the character is dead, publishes [secondsLeft] for the UI,
/// and calls `reviveCharacter()` as soon as recovery is due.
///
/// The remaining time is always recomputed from the wall clock rather than
/// decremented, because Dart timers are throttled while the app is backgrounded.
class DeathRecoveryService extends GetxService {
  static DeathRecoveryService get to => Get.find();

  /// Seconds until the hero revives; 0 while alive or once recovery is due.
  final secondsLeft = 0.obs;

  /// Retry cadence after a failed revive attempt (offline / storage hiccup).
  static const reviveRetryDelay = Duration(seconds: 15);

  Timer? _ticker;
  StreamSubscription<Character?>? _characterSub;
  bool _reviving = false;
  int _nextAttemptAt = 0;

  @override
  void onInit() {
    super.onInit();
    // Fires on every character write: splash load, task completion, damage.
    _characterSub = UserService.to.character.listen((_) => sync());
    sync();
  }

  /// Recomputes the death state and (re)schedules recovery. Safe to call at any
  /// time, from anywhere.
  void sync() {
    final char = UserService.to.character.value;
    if (char == null || !char.isDead) {
      _stopTicker();
      secondsLeft.value = 0;
      return;
    }
    _refreshSeconds();
    if (secondsLeft.value <= 0) {
      _attemptRevive();
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final char = UserService.to.character.value;
    if (char == null || !char.isDead) {
      _stopTicker();
      secondsLeft.value = 0;
      return;
    }
    _refreshSeconds();
    if (secondsLeft.value <= 0) _attemptRevive();
  }

  void _refreshSeconds() {
    final until = UserService.to.character.value?.deathRecoveryUntil.toInt() ?? 0;
    final remainingMs = until - DateTime.now().millisecondsSinceEpoch;
    secondsLeft.value = remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
  }

  /// Revives once the countdown has elapsed; retries after [reviveRetryDelay] if
  /// the first attempt fails.
  void _attemptRevive() {
    if (_reviving) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < _nextAttemptAt) return;
    _nextAttemptAt = now + reviveRetryDelay.inMilliseconds;
    unawaited(_revive());
  }

  Future<void> _revive() async {
    _reviving = true;
    try {
      final unlockedBefore = await AchievementUnlockService.snapshotUnlockedIds();
      await NetworkRegistry.ins.reviveCharacter();
      await UserService.to.loadCharacter();
      await UserService.to.loadUserPrefs();
      _stopTicker();
      secondsLeft.value = 0;
      final unlocked = await AchievementUnlockService.newlyUnlockedSince(unlockedBefore);
      await AchievementUnlockService.presentUnlocks(unlocked);
      if (!(UserService.to.character.value?.isDead ?? false)) {
        Toast.success(LanKey.revived.tr);
      }
    } catch (_) {
      // Offline or a storage hiccup: keep the ticker alive so the next tick
      // retries once [reviveRetryDelay] has passed.
    } finally {
      _reviving = false;
    }
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void onClose() {
    _stopTicker();
    _characterSub?.cancel();
    _characterSub = null;
    super.onClose();
  }

  /// `M:SS` label for the recovery countdown.
  static String formatRemaining(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
