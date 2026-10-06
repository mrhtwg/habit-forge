import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/services/entitlement_service.dart';
import 'package:habit_forge_app/core/services/firebase_session.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Owns Play Billing purchases and the tier the rest of the app reads.
///
/// Freemium rules (store / cloud builds):
/// - Free: 3 habits, warrior only, week stats, ads, no legendary gear
/// - Premium (monthly/yearly/lifetime): unlocks the rest
/// - Yearly/Lifetime: yearly exclusive shop ids
///
/// Premium is always server-authoritative. The client launches Play Billing and
/// forwards the purchase token, but only a verified Firestore entitlement can
/// unlock paid features.
class SubscriptionService extends GetxService {
  static SubscriptionService get to => Get.find();

  final tier = SubscriptionTier.free.obs;
  final isStoreAvailable = false.obs;
  final products = <ProductDetails>[].obs;
  final isBusy = false.obs;
  final purchaseState = PurchaseFlowState.idle.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _iap = InAppPurchase.instance;

  Future<SubscriptionService> init() async {
    await SpUtils.ins.remove('subscription_tier');
    tier.value = EntitlementService.to.serverTier.value ?? SubscriptionTier.free;
    ever(EntitlementService.to.serverTier, (serverTier) {
      tier.value = serverTier ?? SubscriptionTier.free;
    });
    await _initBilling();
    return this;
  }

  /// Store connection and product list. Restore runs only after a linked cloud
  /// identity exists, so every receipt has an account to verify against.
  Future<void> _initBilling() async {
    try {
      final available = await _iap.isAvailable();
      isStoreAvailable.value = available;
      if (!available) {
        Log.w('IAP store unavailable');
        return;
      }
      _purchaseSub = _iap.purchaseStream.listen(
        _onPurchases,
        onError: (e) => Log.e('IAP stream error: $e'),
      );
      await refreshProducts();
    } catch (e) {
      Log.w('IAP init failed: $e');
      isStoreAvailable.value = false;
    }
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    super.onClose();
  }

  bool get isPremium => tier.value.isPremium;
  bool get showAds => !isPremium;
  bool get hasYearlyExtras => tier.value.hasYearlyExtras;

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
  bool get isProcessing => switch (purchaseState.value) {
        PurchaseFlowState.launching || PurchaseFlowState.restoring || PurchaseFlowState.verifying => true,
        _ => false,
      };

  Future<void> refreshProducts() async {
    if (!isStoreAvailable.value) return;
    final resp = await _iap.queryProductDetails(SubscriptionProducts.all.toSet());
    if (resp.error != null) {
      Log.w('queryProductDetails: ${resp.error}');
    }
    products.assignAll(resp.productDetails);
  }

  Future<PurchaseFlowResult> buy(SubscriptionTier target) async {
    if (!FirebaseSession.hasLinkedCloudUser) return PurchaseFlowResult.signInRequired;
    if (target == SubscriptionTier.free || !isStoreAvailable.value) return PurchaseFlowResult.unavailable;
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
      return PurchaseFlowResult.unavailable;
    }
    if (target == SubscriptionTier.lifetime &&
        (tier.value == SubscriptionTier.monthly || tier.value == SubscriptionTier.yearly)) {
      return PurchaseFlowResult.cancelSubscriptionFirst;
    }
    isBusy.value = true;
    purchaseState.value = PurchaseFlowState.launching;
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final accountToken = EntitlementService.accountTokenFor(uid);
      final param = await _purchaseParam(details, target, accountToken);
      final launched = await _iap.buyNonConsumable(purchaseParam: param);
      if (!launched) {
        purchaseState.value = PurchaseFlowState.idle;
        return PurchaseFlowResult.canceled;
      }
      return PurchaseFlowResult.started;
    } catch (e) {
      Log.w('purchase launch failed: $e');
      purchaseState.value = PurchaseFlowState.failed;
      return PurchaseFlowResult.failed;
    } finally {
      isBusy.value = false;
    }
  }

  Future<PurchaseParam> _purchaseParam(
    ProductDetails details,
    SubscriptionTier target,
    String accountToken,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android || target == SubscriptionTier.lifetime) {
      return PurchaseParam(productDetails: details, applicationUserName: accountToken);
    }
    final addition = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases(applicationUserName: accountToken);
    final old = response.pastPurchases.where((purchase) {
      return purchase.status == PurchaseStatus.purchased &&
          (purchase.productID == SubscriptionProducts.monthly || purchase.productID == SubscriptionProducts.yearly) &&
          purchase.productID != details.id;
    }).firstOrNull;
    if (old == null) {
      return GooglePlayPurchaseParam(productDetails: details, applicationUserName: accountToken);
    }
    final replacementMode =
        target == SubscriptionTier.yearly ? ReplacementMode.withTimeProration : ReplacementMode.deferred;
    return GooglePlayPurchaseParam(
      productDetails: details,
      applicationUserName: accountToken,
      changeSubscriptionParam: ChangeSubscriptionParam(
        oldPurchaseDetails: old,
        replacementMode: replacementMode,
      ),
    );
  }

  Future<bool> restorePurchases({bool silent = false}) async {
    if (!FirebaseSession.hasLinkedCloudUser || !isStoreAvailable.value) return false;
    isBusy.value = true;
    purchaseState.value = PurchaseFlowState.restoring;
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _iap.restorePurchases(applicationUserName: EntitlementService.accountTokenFor(uid));
      return true;
    } catch (e) {
      if (!silent) Log.w('restorePurchases: $e');
      purchaseState.value = PurchaseFlowState.failed;
      return false;
    } finally {
      isBusy.value = false;
      if (purchaseState.value == PurchaseFlowState.restoring) {
        purchaseState.value = PurchaseFlowState.idle;
      }
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) {
        purchaseState.value = PurchaseFlowState.pending;
        continue;
      }
      if (p.status == PurchaseStatus.canceled) {
        purchaseState.value = PurchaseFlowState.idle;
        continue;
      }
      if (p.status == PurchaseStatus.error) {
        Log.w('Purchase error: ${p.error}');
        purchaseState.value = PurchaseFlowState.failed;
        continue;
      }
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        purchaseState.value = PurchaseFlowState.verifying;
        final verification = await _requestVerification(p);
        if (verification == PurchaseVerificationStatus.verified) {
          purchaseState.value = PurchaseFlowState.verified;
          if (p.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(p);
            } catch (e) {
              Log.w('client purchase acknowledgement failed after server verification: $e');
            }
          }
        } else if (verification == PurchaseVerificationStatus.pending) {
          purchaseState.value = PurchaseFlowState.pending;
        } else {
          purchaseState.value = PurchaseFlowState.failed;
        }
      }
    }
  }

  /// Asks the server to verify a store receipt (`docs/data-ledger-plan.md` §3.3).
  ///
  /// The receipt travels to `users/{uid}/purchaseRequests`; the Function checks
  /// it with Play/App Store and publishes the entitlement. Nothing the client
  /// writes here grants premium, so a modified client gains nothing.
  Future<PurchaseVerificationStatus> _requestVerification(PurchaseDetails purchase) async {
    final store = defaultTargetPlatform == TargetPlatform.iOS ? 'apple_app_store' : 'google_play';
    final status = await EntitlementService.to.requestVerification(
      store: store,
      productId: purchase.productID,
      purchaseToken: purchase.verificationData.serverVerificationData,
      orderId: purchase.purchaseID ?? '',
    );
    if (status == PurchaseVerificationStatus.failed || status == PurchaseVerificationStatus.rejected) {
      Log.w('could not request verification for ${purchase.productID}');
    }
    return status;
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

enum PurchaseFlowState { idle, launching, restoring, pending, verifying, verified, failed }

enum PurchaseFlowResult { started, canceled, signInRequired, cancelSubscriptionFirst, unavailable, failed }
