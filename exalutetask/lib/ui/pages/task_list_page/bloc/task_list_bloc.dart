import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:exalutetask/service/api_service.dart';

import '../../../../db/db_functions.dart';
import '../../../../db/model_class.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskLocalDb localDb = TaskLocalDb();

  TaskListBloc() : super(TaskListInitial()) {

    on<TaskListApiEvent>((event, emit) async {
      // 1. Show existing data first
      final initialLocal = await localDb.getTasks();
      emit(TaskListLoaded(tasks: initialLocal));

      try {
        // 2. Process Sync Queue
        final pendingTasks = await localDb.getPendingTasks();

        for (final task in pendingTasks) {
          // Update status to Syncing
          await localDb.updateSyncStatus(task.localId, SyncStatus.syncing);
          emit(TaskListLoaded(tasks: await localDb.getTasks()));

          dynamic res;
          if (task.serverId == null) {
            // New task sync
            res = await ApiService().addTask(task.title);
          }
          else {
            // Update existing task sync
            res = await ApiService().updateTask(task.serverId!, task.completed);
          }

          if (res != null && res.code == null) {
            //api success case
            await localDb.markAsSynced(
              localId: task.localId,
              serverId: res.id.toString(),
            );
          }
          else {
            // Mark as failed if API call failed
            await localDb.updateSyncStatus(task.localId, SyncStatus.syncFailed);
          }
          emit(TaskListLoaded(tasks: await localDb.getTasks()));
        }

        /// 3. FETCH SERVER TASKS FOR SYNC
        final response = await ApiService().getTasks();

        if (response != null && response.code == null) {
          for (final item in response.tasks) {
            final task = LocalTask(
              localId: item.id,
              serverId: item.id,
              title: item.title,
              completed: item.completed == true,
              createdAt: item.createdAt,
              syncStatus: SyncStatus.synced,
            );
            await localDb.upsertFromServer(task);
          }
        }

        /// 4. FINAL STATE FROM LOCAL DB
        final allLocal = await localDb.getTasks();
        emit(TaskListLoaded(tasks: allLocal));

      } catch (e) {
        log("SYNC ERROR: $e");
        final local = await localDb.getTasks();
        emit(TaskListLoaded(tasks: local));
      }
    });


    on<AddTaskEvent>((event, emit) async {
      try {
        final localTask = LocalTask(
          localId: DateTime.now().millisecondsSinceEpoch.toString(),
          serverId: null,
          title: event.title,
          completed: false,
          createdAt: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
          syncStatus: SyncStatus.offline,
        );

        await localDb.insertTask(localTask);
        
        // Refresh UI with offline task
        final all = await localDb.getTasks();
        emit(TaskListLoaded(tasks: all));
        
        // Trigger sync
        add(TaskListApiEvent());

      } catch (e) {
        log("ADD TASK ERROR: $e");
        emit(AddTaskListError("Saved locally"));
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      try {
        /// 1. UPDATE LOCAL FIRST
        await localDb.updateTaskCompleted(
          event.localId,
          event.completed,
        );

        /// 2. REFRESH UI
        final all = await localDb.getTasks();
        emit(TaskListLoaded(tasks: all));

        /// 3. TRIGGER SYNC
        add(TaskListApiEvent());

      } catch (e) {
        log("UPDATE ERROR: $e");
        final all = await localDb.getTasks();
        emit(TaskListLoaded(tasks: all));
      }
    });
  }
}
