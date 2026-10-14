import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/network/hive/game_balance_config.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:uuid/uuid.dart';

class RewardedAdService extends GetxService {
  static RewardedAdService get to => Get.find();

  static const androidTestAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const iOSTestAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  static int get rewardGems => GameBalanceConfig.configuredAdGems;
  static const cooldown = Duration(minutes: 10);
  static int get dailyLimit => GameBalanceConfig.configuredAdClaimsPerDay;

  final isReady = false.obs;
  final isLoading = false.obs;
  final dailyWatchCount = 0.obs;
  final cooldownRemaining = Duration.zero.obs;

  RewardedAd? _rewardedAd;
  Timer? _cooldownTimer;
  String? _usageDay;

  String get _adUnitId => switch (defaultTargetPlatform) {
        TargetPlatform.android => const String.fromEnvironment(
            'adRewardedUnitIdAndroid',
            defaultValue: androidTestAdUnitId,
          ),
        TargetPlatform.iOS => const String.fromEnvironment(
            'adRewardedUnitIdIos',
            defaultValue: iOSTestAdUnitId,
          ),
        _ => '',
      };

  bool get dailyLimitReached {
    _refreshUsageDay();
    return dailyWatchCount.value >= dailyLimit;
  }

  bool get isCoolingDown => cooldownRemaining.value > Duration.zero;

  bool canWatch({bool enforceHomeLimits = true}) {
    return !enforceHomeLimits || (!dailyLimitReached && !isCoolingDown);
  }

  String get cooldownLabel {
    final totalSeconds = cooldownRemaining.value.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<RewardedAdService> init() async {
    await _restoreUsage();
    if (kIsWeb || _adUnitId.isEmpty) return this;
    try {
      await MobileAds.instance.initialize();
      _load();
    } catch (error) {
      Log.w('Google Mobile Ads init failed: $error');
    }
    return this;
  }

  void _load() {
    if (isLoading.value || isReady.value || _adUnitId.isEmpty) return;
    isLoading.value = true;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          isLoading.value = false;
          _rewardedAd = ad;
          isReady.value = true;
        },
        onAdFailedToLoad: (error) {
          isLoading.value = false;
          isReady.value = false;
          Log.w('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  Future<bool> showRewarded({int? gems, int gold = 0, bool enforceHomeLimits = true}) async {
    if (!canWatch(enforceHomeLimits: enforceHomeLimits)) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      _load();
      return false;
    }

    _rewardedAd = null;
    isReady.value = false;
    var rewardGranted = false;
    var dismissed = false;
    var rewardCallbackStarted = false;
    var rewardClaimFinished = false;
    final result = Completer<bool>();
    void completeIfReady() {
      if (dismissed && rewardClaimFinished && !result.isCompleted) {
        result.complete(rewardGranted);
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
        dismissed = true;
        if (!rewardCallbackStarted) rewardClaimFinished = true;
        completeIfReady();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _load();
        Log.w('Rewarded ad failed to show: $error');
        dismissed = true;
        rewardClaimFinished = true;
        completeIfReady();
      },
    );
    ad.show(
      onUserEarnedReward: (_, __) async {
        rewardCallbackStarted = true;
        try {
          final rewardId = const Uuid().v4();
          final rewardGemAmount = gems ?? rewardGems;
          final response = await NetworkRegistry.ins.claimRewardedAdReward(
            rewardId,
            gems: rewardGemAmount,
            gold: gold,
          );
          if (response.isSuccess && response.data != null) {
            UserService.to.userPrefs.value = response.data!.prefs;
            await _recordSuccessfulReward(enforceHomeLimits: enforceHomeLimits);
            rewardGranted = true;
          }
        } finally {
          rewardClaimFinished = true;
          completeIfReady();
        }
      },
    );
    return result.future;
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.onClose();
  }

  Future<void> _restoreUsage() async {
    final today = _dateKey(DateTime.now());
    final storedDay = SpUtils.ins.getString(SpKeys.rewardedAdDay);
    if (storedDay != today) {
      _usageDay = today;
      dailyWatchCount.value = 0;
      await SpUtils.ins.putString(SpKeys.rewardedAdDay, today);
      await SpUtils.ins.putInt(SpKeys.rewardedAdDailyCount, 0);
    } else {
      _usageDay = today;
      dailyWatchCount.value = SpUtils.ins.getInt(SpKeys.rewardedAdDailyCount) ?? 0;
    }
    _refreshCooldown();
  }

  Future<void> _recordSuccessfulReward({required bool enforceHomeLimits}) async {
    if (!enforceHomeLimits) return;
    _refreshUsageDay();
    dailyWatchCount.value++;
    final now = DateTime.now().millisecondsSinceEpoch;
    await SpUtils.ins.putString(SpKeys.rewardedAdDay, _usageDay!);
    await SpUtils.ins.putInt(SpKeys.rewardedAdDailyCount, dailyWatchCount.value);
    cooldownRemaining.value = cooldown;
    await SpUtils.ins.putInt(SpKeys.rewardedAdLastAt, now);
    _startCooldownTimer();
  }

  void _refreshUsageDay() {
    final today = _dateKey(DateTime.now());
    if (_usageDay == today) return;
    _usageDay = today;
    dailyWatchCount.value = 0;
    unawaited(SpUtils.ins.putString(SpKeys.rewardedAdDay, today));
    unawaited(SpUtils.ins.putInt(SpKeys.rewardedAdDailyCount, 0));
  }

  void _refreshCooldown() {
    final lastAt = SpUtils.ins.getInt(SpKeys.rewardedAdLastAt);
    if (lastAt == null) {
      cooldownRemaining.value = Duration.zero;
      return;
    }
    final remaining = cooldown - DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastAt));
    cooldownRemaining.value = remaining.isNegative ? Duration.zero : remaining;
    if (isCoolingDown) {
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshCooldown();
      if (!isCoolingDown) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        _load();
      }
    });
  }

  static String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
