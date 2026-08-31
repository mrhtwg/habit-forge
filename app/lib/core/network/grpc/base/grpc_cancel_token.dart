import 'package:grpc/grpc.dart';

class GrpcCancelToken {
  final List<ResponseFuture> _futures = [];
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
    for (var future in _futures) {
      future.cancel();
    }
    _futures.clear();
  }

  void register(Future future) {
    if (future is ResponseFuture) {
      if (_isCancelled) {
        future.cancel();
      } else {
        _futures.add(future);
      }
    }
  }
}
