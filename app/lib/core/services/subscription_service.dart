import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Owns Play Billing purchases and local entitlement state.
///
/// Freemium rules (store / cloud builds):
/// - Free: 3 habits, warrior only, week stats, ads, no legendary gear
/// - Premium (monthly/yearly/lifetime): unlocks the rest
/// - Yearly/Lifetime: yearly exclusive shop ids
///
/// Hive (local open-source) builds skip IAP and treat every gate as unlocked —
/// self-compiled clients can change one line anyway; locks only add friction.
class SubscriptionService extends GetxService {
  static SubscriptionService get to => Get.find();

  final tier = SubscriptionTier.free.obs;
  final isStoreAvailable = false.obs;
  final products = <ProductDetails>[].obs;
  final isBusy = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _iap = InAppPurchase.instance;

  /// Local-first open builds: no store, full content.
  bool get isHiveUnlocked => EnvConstants.isHive();

  Future<SubscriptionService> init() async {
    final saved = SpUtils.ins.getString(SpKeys.subscriptionTier);
    tier.value = _parseTier(saved);

    if (isHiveUnlocked) {
      Log.d('Hive mode: premium gates unlocked, IAP skipped');
      return this;
    }

    try {
      final available = await _iap.isAvailable();
      isStoreAvailable.value = available;
      if (!available) {
        Log.w('IAP store unavailable — debug unlock still works');
        return this;
      }
      _purchaseSub = _iap.purchaseStream.listen(
        _onPurchases,
        onError: (e) => Log.e('IAP stream error: $e'),
      );
      await refreshProducts();
      await restorePurchases(silent: true);
    } catch (e) {
      Log.w('IAP init failed: $e');
      isStoreAvailable.value = false;
    }
    return this;
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    super.onClose();
  }

  bool get isPremium => isHiveUnlocked || tier.value.isPremium;
  bool get showAds => !isPremium;
  bool get hasYearlyExtras => isHiveUnlocked || tier.value.hasYearlyExtras;

  int get habitSlotLimit => isPremium ? 1 << 20 : SubscriptionLimits.freeHabitSlots;

  bool canCreateHabit(int currentHabitCount) => currentHabitCount < habitSlotLimit;

  bool canUseClass(CharacterClass c) {
    if (isPremium) return true;
    return c == CharacterClass.CHARACTER_CLASS_WARRIOR || c == CharacterClass.CHARACTER_CLASS_UNSPECIFIED;
  }

  /// Legendary gear (and yearly exclusives) require a matching tier.
  bool canAccessShopItem(ShopItem item) {
    if (item.rarity == EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY) {
      return isPremium;
    }
    if (_yearlyExclusiveIds.contains(item.id)) {
      return hasYearlyExtras;
    }
    return true;
  }

  bool get canUseAdvancedStats => isPremium;

  Future<void> refreshProducts() async {
    if (isHiveUnlocked || !isStoreAvailable.value) return;
    final resp = await _iap.queryProductDetails(SubscriptionProducts.all.toSet());
    if (resp.error != null) {
      Log.w('queryProductDetails: ${resp.error}');
    }
    products.assignAll(resp.productDetails);
  }

  Future<bool> buy(SubscriptionTier target) async {
    if (isHiveUnlocked || target == SubscriptionTier.free) return false;
    final productId = switch (target) {
      SubscriptionTier.monthly => SubscriptionProducts.monthly,
      SubscriptionTier.yearly => SubscriptionProducts.yearly,
      SubscriptionTier.lifetime => SubscriptionProducts.lifetime,
      _ => '',
    };
    ProductDetails? details;
    for (final p in products) {
      if (p.id == productId) details = p;
    }
    if (details == null) {
      Log.w('Product $productId not found in store');
      if (kDebugMode) {
        await unlockDebug(target);
        return true;
      }
      return false;
    }
    isBusy.value = true;
    try {
      final param = PurchaseParam(productDetails: details);
      if (target == SubscriptionTier.lifetime) {
        return await _iap.buyNonConsumable(purchaseParam: param);
      }
      return await _iap.buyNonConsumable(purchaseParam: param);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> restorePurchases({bool silent = false}) async {
    if (isHiveUnlocked || !isStoreAvailable.value) return;
    isBusy.value = true;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (!silent) Log.w('restorePurchases: $e');
    } finally {
      isBusy.value = false;
    }
  }

  /// Debug / internal QA unlock (also used when store products are missing).
  Future<void> unlockDebug(SubscriptionTier t) async {
    await _setTier(t);
    Log.d('Debug unlock → $t');
  }

  Future<void> clearEntitlement() async {
    await _setTier(SubscriptionTier.free);
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    var best = tier.value;
    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) continue;
      if (p.status == PurchaseStatus.error) {
        Log.w('Purchase error: ${p.error}');
        continue;
      }
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        final t = SubscriptionProducts.tierForProduct(p.productID);
        if (t != null && t.rank > best.rank) best = t;
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
    if (best.rank > tier.value.rank || best != tier.value) {
      await _setTier(best);
    }
  }

  Future<void> _setTier(SubscriptionTier t) async {
    tier.value = t;
    await SpUtils.ins.putString(SpKeys.subscriptionTier, t.name);
  }

  static SubscriptionTier _parseTier(String? raw) {
    if (raw == null || raw.isEmpty) return SubscriptionTier.free;
    return SubscriptionTier.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => SubscriptionTier.free,
    );
  }

  /// Yearly-plan exclusive cosmetics (from feasibility “年度专属”).
  static const _yearlyExclusiveIds = {
    'sword_dragon',
    'armor_void',
    'helm_sky',
    'chain_eternal',
    'bow_phoenix',
  };
}
