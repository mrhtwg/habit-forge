import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/grpc/base/auth_grpc_interceptor.dart';
import 'package:injectable/injectable.dart';

/// Singleton gRPC channel — only used in **server** mode.
///
/// Construction is lazy so hive/firebase startups do not open a useless
/// `localhost:9000` connection.
@singleton
class GrpcClientChannel {
  ClientChannel? _channel;

  final List<int> retryableErrors = [
    StatusCode.unavailable,
    StatusCode.deadlineExceeded,
    StatusCode.aborted,
    StatusCode.internal,
    StatusCode.unknown,
  ];

  GrpcClientChannel();

  factory GrpcClientChannel.instance() => getIt<GrpcClientChannel>();

  ClientChannel get channel {
    _channel ??= _createChannel();
    return _channel!;
  }

  List<ClientInterceptor> get interceptors => [_authInterceptor];

  final AuthGrpcInterceptor _authInterceptor = AuthGrpcInterceptor();

  Future<void> shutdown() async {
    final ch = _channel;
    if (ch == null) return;
    Log.d('Shutting down gRPC ClientChannel...');
    try {
      await ch.shutdown().timeout(const Duration(seconds: 5));
      Log.d('gRPC ClientChannel shut down successfully.');
    } catch (e) {
      Log.e('Error shutting down gRPC ClientChannel: $e');
    } finally {
      _channel = null;
    }
  }

  ClientChannel _createChannel() {
    if (!EnvConstants.isServer()) {
      Log.w('gRPC channel requested outside server mode — using ${EnvConstants.grpcUrl}');
    }
    final (host, port) = _parseEndpoint(EnvConstants.grpcUrl);
    final ch = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        keepAlive: ClientKeepAliveOptions(
          pingInterval: Duration(seconds: 10),
          timeout: Duration(seconds: 20),
          permitWithoutCalls: false,
        ),
      ),
      channelShutdownHandler: () => {Log.d('ClientChannel shutdown')},
    );
    Log.d('gRPC Channel initialized for $host:$port');
    return ch;
  }

  (String, int) _parseEndpoint(String url) {
    final cleaned = url.replaceAll(RegExp(r'^https?://'), '');
    final parts = cleaned.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9000 : 9000;
    return (host, port);
  }
}
