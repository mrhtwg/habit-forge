import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbgrpc.dart';

class ShopApi extends BaseGrpcApi {
  late final ShopServiceClient _stub;

  Future<ApiResponse<BuyItemReply>> buyItem(String itemId, ShopCurrency currency) async =>
      call(() => _stub.buyItem(BuyItemRequest(itemId: itemId, currency: currency)));
}
