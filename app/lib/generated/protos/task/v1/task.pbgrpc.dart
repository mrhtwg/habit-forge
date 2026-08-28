// This is a generated file - do not edit.
//
// Generated from api/task/v1/task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'task.pb.dart' as $0;

export 'task.pb.dart';

/// TaskService — Habit / Daily / ToDo task management with RPG rewards.
@$pb.GrpcServiceName('api.task.v1.TaskService')
class TaskServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TaskServiceClient(super.channel, {super.options, super.interceptors});

  /// ListTasks lists tasks for the current user with optional filters.
  $grpc.ResponseFuture<$0.ListTasksReply> listTasks(
    $0.ListTasksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTasks, request, options: options);
  }

  /// GetTask returns one task by id.
  $grpc.ResponseFuture<$0.GetTaskReply> getTask(
    $0.GetTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTask, request, options: options);
  }

  /// CreateTask creates a new task.
  $grpc.ResponseFuture<$0.CreateTaskReply> createTask(
    $0.CreateTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTask, request, options: options);
  }

  /// UpdateTask updates an existing task (title, difficulty, tags, skip, etc.).
  $grpc.ResponseFuture<$0.UpdateTaskReply> updateTask(
    $0.UpdateTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateTask, request, options: options);
  }

  /// DeleteTask removes a task.
  $grpc.ResponseFuture<$0.DeleteTaskReply> deleteTask(
    $0.DeleteTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTask, request, options: options);
  }

  /// CompleteTask marks a task completed and grants EXP/gold rewards.
  $grpc.ResponseFuture<$0.CompleteTaskReply> completeTask(
    $0.CompleteTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completeTask, request, options: options);
  }

  // method descriptors

  static final _$listTasks =
      $grpc.ClientMethod<$0.ListTasksRequest, $0.ListTasksReply>(
          '/api.task.v1.TaskService/ListTasks',
          ($0.ListTasksRequest value) => value.writeToBuffer(),
          $0.ListTasksReply.fromBuffer);
  static final _$getTask =
      $grpc.ClientMethod<$0.GetTaskRequest, $0.GetTaskReply>(
          '/api.task.v1.TaskService/GetTask',
          ($0.GetTaskRequest value) => value.writeToBuffer(),
          $0.GetTaskReply.fromBuffer);
  static final _$createTask =
      $grpc.ClientMethod<$0.CreateTaskRequest, $0.CreateTaskReply>(
          '/api.task.v1.TaskService/CreateTask',
          ($0.CreateTaskRequest value) => value.writeToBuffer(),
          $0.CreateTaskReply.fromBuffer);
  static final _$updateTask =
      $grpc.ClientMethod<$0.UpdateTaskRequest, $0.UpdateTaskReply>(
          '/api.task.v1.TaskService/UpdateTask',
          ($0.UpdateTaskRequest value) => value.writeToBuffer(),
          $0.UpdateTaskReply.fromBuffer);
  static final _$deleteTask =
      $grpc.ClientMethod<$0.DeleteTaskRequest, $0.DeleteTaskReply>(
          '/api.task.v1.TaskService/DeleteTask',
          ($0.DeleteTaskRequest value) => value.writeToBuffer(),
          $0.DeleteTaskReply.fromBuffer);
  static final _$completeTask =
      $grpc.ClientMethod<$0.CompleteTaskRequest, $0.CompleteTaskReply>(
          '/api.task.v1.TaskService/CompleteTask',
          ($0.CompleteTaskRequest value) => value.writeToBuffer(),
          $0.CompleteTaskReply.fromBuffer);
}

@$pb.GrpcServiceName('api.task.v1.TaskService')
abstract class TaskServiceBase extends $grpc.Service {
  $core.String get $name => 'api.task.v1.TaskService';

  TaskServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListTasksRequest, $0.ListTasksReply>(
        'ListTasks',
        listTasks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTasksRequest.fromBuffer(value),
        ($0.ListTasksReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTaskRequest, $0.GetTaskReply>(
        'GetTask',
        getTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetTaskRequest.fromBuffer(value),
        ($0.GetTaskReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateTaskRequest, $0.CreateTaskReply>(
        'CreateTask',
        createTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateTaskRequest.fromBuffer(value),
        ($0.CreateTaskReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateTaskRequest, $0.UpdateTaskReply>(
        'UpdateTask',
        updateTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateTaskRequest.fromBuffer(value),
        ($0.UpdateTaskReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteTaskRequest, $0.DeleteTaskReply>(
        'DeleteTask',
        deleteTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteTaskRequest.fromBuffer(value),
        ($0.DeleteTaskReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CompleteTaskRequest, $0.CompleteTaskReply>(
            'CompleteTask',
            completeTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CompleteTaskRequest.fromBuffer(value),
            ($0.CompleteTaskReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListTasksReply> listTasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListTasksRequest> $request) async {
    return listTasks($call, await $request);
  }

  $async.Future<$0.ListTasksReply> listTasks(
      $grpc.ServiceCall call, $0.ListTasksRequest request);

  $async.Future<$0.GetTaskReply> getTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetTaskRequest> $request) async {
    return getTask($call, await $request);
  }

  $async.Future<$0.GetTaskReply> getTask(
      $grpc.ServiceCall call, $0.GetTaskRequest request);

  $async.Future<$0.CreateTaskReply> createTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTaskRequest> $request) async {
    return createTask($call, await $request);
  }

  $async.Future<$0.CreateTaskReply> createTask(
      $grpc.ServiceCall call, $0.CreateTaskRequest request);

  $async.Future<$0.UpdateTaskReply> updateTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateTaskRequest> $request) async {
    return updateTask($call, await $request);
  }

  $async.Future<$0.UpdateTaskReply> updateTask(
      $grpc.ServiceCall call, $0.UpdateTaskRequest request);

  $async.Future<$0.DeleteTaskReply> deleteTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteTaskRequest> $request) async {
    return deleteTask($call, await $request);
  }

  $async.Future<$0.DeleteTaskReply> deleteTask(
      $grpc.ServiceCall call, $0.DeleteTaskRequest request);

  $async.Future<$0.CompleteTaskReply> completeTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CompleteTaskRequest> $request) async {
    return completeTask($call, await $request);
  }

  $async.Future<$0.CompleteTaskReply> completeTask(
      $grpc.ServiceCall call, $0.CompleteTaskRequest request);
}
