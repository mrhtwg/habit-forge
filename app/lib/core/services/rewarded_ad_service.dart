import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:uuid/uuid.dart';

class RewardedAdService extends GetxService {
  static RewardedAdService get to => Get.find();

  static const androidTestAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const iOSTestAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  static const rewardGems = 5;

  final isReady = false.obs;
  final isLoading = false.obs;

  RewardedAd? _rewardedAd;

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

  Future<RewardedAdService> init() async {
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

  Future<bool> showRewarded({int gems = rewardGems, int gold = 0}) async {
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
          final response = await NetworkRegistry.ins.claimRewardedAdReward(
            rewardId,
            gems: gems,
            gold: gold,
          );
          if (response.isSuccess && response.data != null) {
            UserService.to.userPrefs.value = response.data!.prefs;
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
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.onClose();
  }
}
