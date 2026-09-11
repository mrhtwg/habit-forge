import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pbgrpc.dart';

class TaskApi extends BaseGrpcApi {
  TaskApi() {
    _stub = TaskServiceClient(channel, interceptors: interceptors);
  }

  late final TaskServiceClient _stub;

  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async =>
      call(() => _stub.createTask(CreateTaskRequest(task: task)));

  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) async =>
      call(() => _stub.updateTask(UpdateTaskRequest(id: id, task: task)));

  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async =>
      call(() => _stub.deleteTask(DeleteTaskRequest(id: id)));

  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) async =>
      call(
        () => _stub.listTasks(
          ListTasksRequest(
            type: type,
            difficulty: difficulty,
            tags: tags,
            onlyDueToday: onlyDueToday ?? false,
          ),
        ),
      );

  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async =>
      call(() => _stub.completeTask(CompleteTaskRequest(id: id)));

  Future<ApiResponse<SkipTaskReply>> skipTask(String taskId) async =>
      call(() => _stub.skipTask(SkipTaskRequest(id: taskId)));
}
