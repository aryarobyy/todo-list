import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/models/index.dart';
import 'package:to_do_list/service/subtask_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final subTaskServiceProvider = Provider((ref) => SubtaskService());

@immutable
class State {
  final bool isLoading;
  final SubTaskModel? subTask;
  final List<SubTaskModel>? subTasks;
  final String? error;

  const State({
    this.isLoading = false,
    this.subTask,
    this.subTasks,
    this.error,
  });

  State copyWith({
    bool? isLoading,
    SubTaskModel? subTask,
    List<SubTaskModel>? subTasks,
    String? error,
  }) {
    return State(
      isLoading: isLoading ?? this.isLoading,
      subTask: subTask ?? this.subTask,
      subTasks: subTasks ?? this.subTasks,
      error: error ?? this.error,
    );
  }
}

class SubTaskNotifier extends StateNotifier<State> {
  SubTaskNotifier(this._service) : super(const State());
  final SubtaskService _service;

  Future<void> createSubTask({
    required String creatorId,
    required String text,
    required String todoId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      final data = await _service
        .createSubtask(
          creatorId:creatorId,
          todoId: todoId,
          text: text
      );
      state = state.copyWith(isLoading: false, subTask: data);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> updateSubTask({
    required String creatorId,
    required String todoId,
    required String subtaskId,
    required String text,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      final data = await _service
        .UpdateSubtask(
          creatorId:creatorId,
          todoId: todoId,
          subtaskId: subtaskId,
          text: text,
      );
      state = state.copyWith(isLoading: false, subTask: data);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> changeStatus({
    required bool isDone,
    required String creatorId,
    required String todoId,
    required String subtaskId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      await _service
        .changeStatus(
          isDone: isDone,
          creatorId:creatorId,
          todoId: todoId,
          subtaskId: subtaskId,
      );
      state = state.copyWith(isLoading: false);
      return;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> getSubTaskById({
    required String creatorId,
    required String todoId,
    required String subtaskId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      final data = await _service
        .getSubtaskById(
          creatorId:creatorId,
          todoId: todoId,
          subtaskId: subtaskId,
      );
      state = state.copyWith(isLoading: false, subTask: data);
      return;
    } catch (e) {
      state = state.copyWith(subTask: null, error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> getSubTask({
    required String creatorId,
    required String todoId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      final data = await _service
        .getSubtask(
          creatorId:creatorId,
          todoId: todoId,
      );
      state = state.copyWith(isLoading: false, subTasks: data);
    } catch(e) {
      state = state.copyWith(subTasks: null, error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteSubTask({
    required String creatorId,
    required String todoId,
    required String subtaskId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try{
      await _service
        .deleteSubtask(
          creatorId:creatorId,
          todoId: todoId,
          subtaskId: subtaskId,
      );
      state = state.copyWith(isLoading: false);
    } catch(e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final subTaskNotifierProvider = StateNotifierProvider<SubTaskNotifier, State>(
      (ref) => SubTaskNotifier(ref.read(subTaskServiceProvider)),
);