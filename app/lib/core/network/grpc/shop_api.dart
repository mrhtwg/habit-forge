import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbgrpc.dart';

class ShopApi extends BaseGrpcApi {
  ShopApi() {
    _stub = ShopServiceClient(channel, interceptors: interceptors);
  }

  late final ShopServiceClient _stub;

  Future<ApiResponse<ListShopItemsReply>> listShopItems() async =>
      call(() => _stub.listShopItems(ListShopItemsRequest()));

  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() async =>
      call(() => _stub.listOwnedItems(ListOwnedItemsRequest()));

  Future<ApiResponse<BuyItemReply>> buyItem(String itemId, ShopCurrency currency) async =>
      call(() => _stub.buyItem(BuyItemRequest(itemId: itemId, currency: currency)));

  Future<ApiResponse<GetDailyDealReply>> getDailyDeal() async =>
      call(() => _stub.getDailyDeal(GetDailyDealRequest()));
}
