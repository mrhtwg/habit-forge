import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/grpc_cancel_token.dart';
import 'package:habit_forge_app/core/network/grpc/grpc_client_channel.dart';

/// 所有 gRPC API 类的基类
abstract class BaseGrpcApi {
  /// Token 过期标志，当检测到 AUTH_TOKEN_EXPIRED 时设置为 true
  /// 阻止后续所有网络请求执行
  static bool _isTokenExpired = false;

  /// 获取底层 ClientChannel
  ClientChannel get channel => _grpcChannel.channel;

  /// 获取拦截器列表（用于创建 gRPC stub）
  List<ClientInterceptor> get interceptors => _grpcChannel.interceptors;

  /// 获取 GrpcClientChannel 实例
  GrpcClientChannel get _grpcChannel => GrpcClientChannel.instance();

  Future<ApiResponse<T>> call<T>(
    Future<T> Function() operation, {
    GrpcCancelToken? cancelToken,
    bool? resetTokenExpiredFlag,
  }) async {
    if (resetTokenExpiredFlag ?? false) {
      BaseGrpcApi.resetTokenExpiredFlag();
    }
    // 检查 token 是否已过期，如果已过期则直接返回错误，不执行请求
    if (_isTokenExpired) {
      Log.w('Request blocked: token has expired');
    }

    // 检查是否已取消
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
          // 只在重试成功时记录日志，减少日志开销
          if (attempt > 1) {
            Log.network('Request succeeded on attempt $attempt');
          }

          return ApiResponse.success(data);
        } on GrpcError catch (e) {
          // 检查是否是取消操作
          if (e.code == StatusCode.cancelled) {
            Log.w('Request cancelled');
            return ApiResponse.fromGrpcError(e.code, 'Request cancelled', errorReasonValue: null, reason: null);
          }

          // 提取错误信息
          String? errorReason = _extractErrorReason(e);

          // 检查是否是业务错误（不应该重试）
          if (_isBusinessError(e, errorReason)) {
            return _handleBusinessError(e, errorReason);
          }
          if (e.code == StatusCode.unavailable && e.codeName == StatusCode.name(StatusCode.unavailable)) {
            return ApiResponse.fromGrpcError(e.code, 'Network error', errorReasonValue: null, reason: errorReason);
          }
          // 检查是否应该重试
          if (_shouldRetry(e) && attempt < maxRetries) {
            final backoff = _calculateBackoff(attempt, initialBackoff, maxBackoff);
            Log.w(
              'gRPC error on attempt $attempt: ${e.code} - ${e.message}, retrying after ${backoff.inMilliseconds}ms',
            );
            await Future.delayed(backoff);
            continue; // 继续下一次重试
          }

          // 不应该重试或已达到最大重试次数
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

      // 理论上不应该到达这里
      return ApiResponse.fromException(Exception('Max retries exceeded'));
    } finally {}
  }

  /// 计算退避时间（指数退避 + 抖动）
  Duration _calculateBackoff(int attempt, Duration initialBackoff, Duration maxBackoff) {
    // 基础退避时间 = initialBackoff * (2 ^ (attempt - 1))
    int baseBackoffMillis = initialBackoff.inMilliseconds * (1 << (attempt - 1));
    // 添加抖动：生成一个 0 到 baseBackoffMillis/2 之间的随机值
    int jitter = baseBackoffMillis ~/ 2;
    int randomJitter = (jitter * (DateTime.now().microsecondsSinceEpoch % 1000) / 1000).round();
    int backoffWithJitter = baseBackoffMillis + randomJitter;
    Duration backoff = Duration(milliseconds: backoffWithJitter);
    // 限制最大退避时间
    return backoff.compareTo(maxBackoff) > 0 ? maxBackoff : backoff;
  }

  /// 提取错误原因
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
    // 其他业务错误
    Log.e('Business error: ${error.code} - ${error.message} - error_reason: $errorReason');
    return ApiResponse.fromGrpcError(
      error.code,
      error.message ?? 'Business error',
      errorReasonValue: null,
      reason: errorReason,
    );
  }

  /// 判断是否是业务错误（不应该重试）
  bool _isBusinessError(GrpcError error, String? errorReason) {
    return !_grpcChannel.retryableErrors.contains(error.code);
  }

  /// 判断是否应该重试（网络错误）
  bool _shouldRetry(GrpcError error) {
    const retryableCodes = [
      StatusCode.unavailable, // 服务不可用
      StatusCode.deadlineExceeded, // 超时
      // StatusCode.resourceExhausted, // 资源耗尽
      StatusCode.aborted, // 操作被中止
      StatusCode.internal, // 内部错误
      StatusCode.unknown, // 未知错误
    ];

    return retryableCodes.contains(error.code);
  }

  /// 重置 token 过期标志（登录成功后调用）
  static void resetTokenExpiredFlag() {
    _isTokenExpired = false;
    Log.d('Token expired flag reset');
  }
}
