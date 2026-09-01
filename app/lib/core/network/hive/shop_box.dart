import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
class ShopBox {
  static ShopBox get ins => getIt<ShopBox>();

  ShopBox();

  final _boxKey = 'shopBox';

  late Box _shopBox;

  Future init() async {
    _shopBox = await Hive.openBox(_boxKey);
  }

  Future<List<ShopItem>> listItems() async {
    await ShopConfig.load();
    return ShopConfig.shopItems;
  }

  void clear() {
    _shopBox.clear();
  }
}
