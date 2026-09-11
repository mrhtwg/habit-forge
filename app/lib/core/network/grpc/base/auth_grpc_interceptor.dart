import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

/// Attaches `Authorization: Bearer <token>` from [UserService] to every call.
class AuthGrpcInterceptor extends ClientInterceptor {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final token = Get.isRegistered<UserService>() ? UserService.to.token.value : '';
    final merged = options.mergedWith(
      CallOptions(
        metadata: {
          if (token.isNotEmpty) 'authorization': 'Bearer $token',
        },
      ),
    );
    return invoker(method, request, merged);
  }
}
