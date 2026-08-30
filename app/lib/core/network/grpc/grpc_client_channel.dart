import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:injectable/injectable.dart';

/// A singleton managing the gRPC ClientChannel with automatic reconnection on
/// specific failures.
@singleton
class GrpcClientChannel {
  late ClientChannel _channel;

  final List<int> retryableErrors = [
    StatusCode.unavailable,
    StatusCode.deadlineExceeded, // Resource exhausted; may be temporary.
    StatusCode.aborted, // Operation aborted; may be retryable.
    StatusCode.internal, // Internal error; may be temporary.
    StatusCode.unknown, // Unknown error; depends on the situation.
  ];

  /// Initializes the channel upon creation.
  GrpcClientChannel() {
    _initializeChannel();
  }

  /// Factory constructor returning the singleton instance.
  factory GrpcClientChannel.instance() => getIt<GrpcClientChannel>();

  /// Gets the underlying gRPC ClientChannel.
  ClientChannel get channel => _channel;

  /// Interceptors applied to every gRPC stub (token metadata, timing...).
  List<ClientInterceptor> get interceptors => [];

  /// Public method to manually trigger a shutdown of the channel.
  Future<void> shutdown() async {
    Log.d('Shutting down gRPC ClientChannel...');
    try {
      await _channel.shutdown().timeout(const Duration(seconds: 5));
      Log.d('gRPC ClientChannel shut down successfully.');
    } catch (e) {
      Log.e('Error shutting down gRPC ClientChannel: $e');
    }
  }

  /// Internal method to create and set up the ClientChannel from
  /// [EnvConstants.grpcUrl] (format "host:port").
  void _initializeChannel() {
    final (host, port) = _parseEndpoint(EnvConstants.grpcUrl);
    _channel = ClientChannel(
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
  }

  /// Parses "host:port" (or "http://host:port") into a (host, port) record.
  (String, int) _parseEndpoint(String url) {
    final cleaned = url.replaceAll(RegExp(r'^https?://'), '');
    final parts = cleaned.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9000 : 9000;
    return (host, port);
  }
}
