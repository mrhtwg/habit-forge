// This is a generated file - do not edit.
//
// Generated from task/v1/task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'task.pb.dart' as $0;
import 'task.pbjson.dart';

export 'task.pb.dart';

abstract class TaskServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListTasksReply> listTasks(
      $pb.ServerContext ctx, $0.ListTasksRequest request);
  $async.Future<$0.GetTaskReply> getTask(
      $pb.ServerContext ctx, $0.GetTaskRequest request);
  $async.Future<$0.CreateTaskReply> createTask(
      $pb.ServerContext ctx, $0.CreateTaskRequest request);
  $async.Future<$0.UpdateTaskReply> updateTask(
      $pb.ServerContext ctx, $0.UpdateTaskRequest request);
  $async.Future<$0.DeleteTaskReply> deleteTask(
      $pb.ServerContext ctx, $0.DeleteTaskRequest request);
  $async.Future<$0.CompleteTaskReply> completeTask(
      $pb.ServerContext ctx, $0.CompleteTaskRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListTasks':
        return $0.ListTasksRequest();
      case 'GetTask':
        return $0.GetTaskRequest();
      case 'CreateTask':
        return $0.CreateTaskRequest();
      case 'UpdateTask':
        return $0.UpdateTaskRequest();
      case 'DeleteTask':
        return $0.DeleteTaskRequest();
      case 'CompleteTask':
        return $0.CompleteTaskRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListTasks':
        return listTasks(ctx, request as $0.ListTasksRequest);
      case 'GetTask':
        return getTask(ctx, request as $0.GetTaskRequest);
      case 'CreateTask':
        return createTask(ctx, request as $0.CreateTaskRequest);
      case 'UpdateTask':
        return updateTask(ctx, request as $0.UpdateTaskRequest);
      case 'DeleteTask':
        return deleteTask(ctx, request as $0.DeleteTaskRequest);
      case 'CompleteTask':
        return completeTask(ctx, request as $0.CompleteTaskRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TaskServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => TaskServiceBase$messageJson;
}
