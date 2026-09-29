import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';

/// The deal of the day is what the shop advertises and what the purchase path
/// charges, so both must come from the same math.
void main() {
  test('deal is stable within a local day', () {
    final morning = ShopConfig.dailyDealFor('user-1', DateTime(2026, 9, 28, 0, 5));
    final evening = ShopConfig.dailyDealFor('user-1', DateTime(2026, 9, 28, 23, 55));
    expect(evening.itemId, morning.itemId);
    expect(evening.discountPercent, morning.discountPercent);
    expect(evening.expiresAt.toInt(), morning.expiresAt.toInt());
  });

  test('deal expires at local midnight', () {
    final deal = ShopConfig.dailyDealFor('user-1', DateTime(2026, 9, 28, 23, 0));
    expect(DateTime.fromMillisecondsSinceEpoch(deal.expiresAt.toInt()), DateTime(2026, 9, 29));
    expect(deal.discountPercent, greaterThan(0));
  });

  test('deal never lands on premium-only legendary gear', () {
    for (var day = 1; day <= 28; day++) {
      final deal = ShopConfig.dailyDealFor('user-$day', DateTime(2026, 9, day));
      final matches = ShopConfig.shopItems.where((i) => i.id == deal.itemId);
      expect(matches, isNotEmpty, reason: 'deal must point at a real catalog item');
      expect(matches.first.rarity, isNot(EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY));
    }
  });

  test('effectivePrice discounts only the deal item, rounding down', () {
    final deal = DailyDeal()
      ..itemId = 'sword_flame'
      ..discountPercent = 30;
    expect(ShopConfig.effectivePrice(500, 'sword_flame', deal), 350);
    expect(ShopConfig.effectivePrice(500, 'armor_golden', deal), 500);
    expect(ShopConfig.effectivePrice(500, 'sword_flame', null), 500);
    expect(ShopConfig.effectivePrice(99, 'sword_flame', deal), 69);
    final zero = DailyDeal()
      ..itemId = 'sword_flame'
      ..discountPercent = 0;
    expect(ShopConfig.effectivePrice(500, 'sword_flame', zero), 500);
  });
}
