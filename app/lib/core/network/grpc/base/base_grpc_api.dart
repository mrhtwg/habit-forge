import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/grpc_cancel_token.dart';
import 'package:habit_forge_app/core/network/grpc/base/grpc_client_channel.dart';

abstract class BaseGrpcApi {
  static bool _isTokenExpired = false;

  ClientChannel get channel => _grpcChannel.channel;

  List<ClientInterceptor> get interceptors => _grpcChannel.interceptors;

  GrpcClientChannel get _grpcChannel => GrpcClientChannel.instance();

  Future<ApiResponse<T>> call<T>(
    Future<T> Function() operation, {
    GrpcCancelToken? cancelToken,
    bool? resetTokenExpiredFlag,
  }) async {
    if (resetTokenExpiredFlag ?? false) {
      BaseGrpcApi.resetTokenExpiredFlag();
    }
    if (_isTokenExpired) {
      Log.w('Request blocked: token has expired');
    }

    if (cancelToken?.isCancelled ?? false) {
      Log.w('Request cancelled before execution');
      return ApiResponse.fromGrpcError(StatusCode.cancelled, 'Request cancelled', errorReasonValue: null, reason: null);
    }

    try {
      const maxRetries = 3;
      const initialBackoff = Duration(milliseconds: 500);
      const maxBackoff = Duration(seconds: 30);

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          final future = operation();
          cancelToken?.register(future);
          final data = await future;
          if (attempt > 1) {
            Log.network('Request succeeded on attempt $attempt');
          }

          return ApiResponse.success(data);
        } on GrpcError catch (e) {
          if (e.code == StatusCode.cancelled) {
            Log.w('Request cancelled');
            return ApiResponse.fromGrpcError(e.code, 'Request cancelled', errorReasonValue: null, reason: null);
          }

          String? errorReason = _extractErrorReason(e);

          if (_isBusinessError(e, errorReason)) {
            return _handleBusinessError(e, errorReason);
          }
          if (e.code == StatusCode.unavailable && e.codeName == StatusCode.name(StatusCode.unavailable)) {
            return ApiResponse.fromGrpcError(e.code, 'Network error', errorReasonValue: null, reason: errorReason);
          }
          if (_shouldRetry(e) && attempt < maxRetries) {
            final backoff = _calculateBackoff(attempt, initialBackoff, maxBackoff);
            Log.w(
              'gRPC error on attempt $attempt: ${e.code} - ${e.message}, retrying after ${backoff.inMilliseconds}ms',
            );
            await Future.delayed(backoff);
            continue;
          }

          Log.e('gRPC error (after $attempt attempts): ${e.code} - ${e.message}');
          String? message = e.message;
          if (e.code == StatusCode.unavailable && e.codeName == StatusCode.name(StatusCode.unavailable)) {
            message = 'Network error';
          }
          return ApiResponse.fromGrpcError(
            e.code,
            message ?? 'Unknown gRPC error',
            errorReasonValue: null,
            reason: errorReason,
          );
        } catch (e, s) {
          Log.e('Unexpected error in gRPC call: $e', error: e, stackTrace: s);
          return ApiResponse.fromException(e is Exception ? e : Exception(e.toString()));
        }
      }

      return ApiResponse.fromException(Exception('Max retries exceeded'));
    } finally {}
  }

  Duration _calculateBackoff(int attempt, Duration initialBackoff, Duration maxBackoff) {
    int baseBackoffMillis = initialBackoff.inMilliseconds * (1 << (attempt - 1));
    int jitter = baseBackoffMillis ~/ 2;
    int randomJitter = (jitter * (DateTime.now().microsecondsSinceEpoch % 1000) / 1000).round();
    int backoffWithJitter = baseBackoffMillis + randomJitter;
    Duration backoff = Duration(milliseconds: backoffWithJitter);
    return backoff.compareTo(maxBackoff) > 0 ? maxBackoff : backoff;
  }

  String? _extractErrorReason(GrpcError error) {
    try {
      if (error.details != null && error.details!.isNotEmpty) {
        return error.details!.first.writeToJsonMap()['1'];
      }
    } catch (e) {
      Log.w('Failed to parse error_reason from gRPC details: ${error.details}');
    }
    return null;
  }

  ApiResponse<T> _handleBusinessError<T>(GrpcError error, String? errorReason) {
    Log.e('Business error: ${error.code} - ${error.message} - error_reason: $errorReason');
    return ApiResponse.fromGrpcError(
      error.code,
      error.message ?? 'Business error',
      errorReasonValue: null,
      reason: errorReason,
    );
  }

  bool _isBusinessError(GrpcError error, String? errorReason) {
    return !_grpcChannel.retryableErrors.contains(error.code);
  }

  bool _shouldRetry(GrpcError error) {
    const retryableCodes = [
      StatusCode.unavailable,
      StatusCode.deadlineExceeded,
      StatusCode.resourceExhausted,
      StatusCode.aborted,
      StatusCode.internal,
      StatusCode.unknown,
    ];

    return retryableCodes.contains(error.code);
  }

  static void resetTokenExpiredFlag() {
    _isTokenExpired = false;
    Log.d('Token expired flag reset');
  }
}
