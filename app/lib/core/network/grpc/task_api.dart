import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pbgrpc.dart';

class TaskApi extends BaseGrpcApi {
  late final TaskServiceClient _stub;

  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async =>
      call(() => _stub.createTask(CreateTaskRequest(task: task)));

  Future<ApiResponse<GetTaskReply>> getTask() async => call(() => _stub.getTask(GetTaskRequest()));

  Future<ApiResponse<SkipTaskReply>> skipTask(String taskId) async =>
      call(() => _stub.skipTask(SkipTaskRequest(id: taskId)));
}
