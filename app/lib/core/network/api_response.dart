import 'package:protobuf/protobuf.dart' as $pb;

/// Wrapper for API responses.
/// Contains the call result and the returned data.
class ApiResponse<T> {
  /// The call result (code and message).
  final ApiResult result;

  /// The returned data (may be null).
  final T? data;

  const ApiResponse({required this.result, this.data});

  /// Creates a failure response.
  factory ApiResponse.failure({required int code, required String message, T? data, int? errorReasonValue}) {
    return ApiResponse(
      result: ApiResult.failure(code: code, message: message, errorReasonValue: errorReasonValue),
      data: data,
    );
  }

  /// Creates a failure response from an exception.
  factory ApiResponse.fromException(Exception error) {
    return ApiResponse(result: ApiResult.fromException(error), data: null);
  }

  /// Creates a failure response from a gRPC error.
  factory ApiResponse.fromGrpcError(int code, String message, {int? errorReasonValue, String? reason}) {
    return ApiResponse(
      result: ApiResult.fromGrpcError(code, message, errorReasonValue: errorReasonValue, reason: reason),
      data: null,
    );
  }

  /// Creates a success response.
  factory ApiResponse.success(T data, [String message = 'Success']) {
    return ApiResponse(result: ApiResult.success(message), data: data);
  }

  /// The status code.
  int get code => result.code;

  String? get errorReason => result.errorReason;

  /// The int value of the error reason.
  int? get errorReasonValue => result.errorReasonValue;

  /// Whether the call failed.
  bool get isFailure => result.isFailure;

  /// Whether the API call succeeded.
  bool get isOk => code == 0;

  /// Whether the call succeeded.
  bool get isSuccess => result.isSuccess;

  /// The result message.
  String get message => result.message;

  /// Resolves the typed [ErrorReason].
  ///
  /// Example:
  /// ```dart
  /// import 'package:tata/generated/protos/common/v1/common_error.pbenum.dart' as common;
  ///
  /// final errorReason = response.getErrorReason(common.ErrorReason.valueOf);
  /// if (errorReason == common.ErrorReason.NOT_LOGIN) {
  ///   // handle not logged in
  /// }
  /// ```
  T? getErrorReason<T extends $pb.ProtobufEnum>(T? Function(int) valueOf) {
    return result.getErrorReason(valueOf);
  }

  /// Returns the data, or [defaultValue] on failure.
  T getOrDefault(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Returns the data, or throws on failure.
  T getOrThrow() {
    if (isFailure || data == null) {
      throw Exception('API call failed: ${result.message}');
    }
    return data as T;
  }

  /// Maps the data.
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResponse.success(mapper(data as T), message);
      } catch (e) {
        return ApiResponse.fromException(e as Exception);
      }
    }
    return ApiResponse(result: result, data: null);
  }

  @override
  String toString() => 'ApiResponse(result: $result, data: $data)';

  /// Runs [onSuccess] with the data, or [onFailure] with the code and message.
  void when({required void Function(T data) onSuccess, required void Function(int code, String message) onFailure}) {
    if (isSuccess && data != null) {
      onSuccess(data as T);
    } else {
      onFailure(code, message);
    }
  }
}

/// Result of an API call.
/// Contains the status code and message.
class ApiResult {
  /// Status code (0 means success, non-zero means failure).
  final int code;

  /// The result message.
  final String message;

  /// Int value of the error reason (maps to error_reason in proto).
  // ignore: unintended_html_in_doc_comment
  /// Can be converted to a typed ErrorReason enum via [getErrorReason].
  final int? errorReasonValue;

  final String? errorReason;

  const ApiResult({required this.code, required this.message, this.errorReasonValue, this.errorReason});

  /// Creates a failure result.
  factory ApiResult.failure({required int code, required String message, int? errorReasonValue}) {
    return ApiResult(code: code, message: message, errorReasonValue: errorReasonValue);
  }

  /// Creates a failure result from an exception.
  factory ApiResult.fromException(Exception error) {
    return ApiResult(code: -1, message: error.toString());
  }

  /// Creates a failure result from a gRPC error.
  factory ApiResult.fromGrpcError(int code, String message, {int? errorReasonValue, String? reason}) {
    return ApiResult(code: code, message: message, errorReasonValue: errorReasonValue, errorReason: reason);
  }

  /// Creates a success result.
  factory ApiResult.success([String message = 'Success']) {
    return ApiResult(code: 0, message: message);
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ (errorReasonValue?.hashCode ?? 0);

  /// Whether the result is a failure.
  bool get isFailure => !isSuccess;

  /// Whether the result is a success.
  bool get isSuccess => code == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResult &&
        other.code == code &&
        other.message == message &&
        other.errorReasonValue == errorReasonValue;
  }

  /// Resolves the typed ErrorReason.
  ///
  /// Example:
  /// ```dart
  /// import 'package:tata/generated/protos/common/v1/common_error.pbenum.dart' as common;
  ///
  /// final errorReason = result.getErrorReason(common.ErrorReason.valueOf);
  /// if (errorReason == common.ErrorReason.NOT_LOGIN) {
  ///   // handle not logged in
  /// }
  /// ```
  T? getErrorReason<T extends $pb.ProtobufEnum>(T? Function(int) valueOf) {
    if (errorReasonValue == null) return null;
    return valueOf(errorReasonValue!);
  }

  @override
  String toString() =>
      'ApiResult(code: $code, message: $message${errorReasonValue != null ? ', errorReason: $errorReasonValue' : ''})';
}
