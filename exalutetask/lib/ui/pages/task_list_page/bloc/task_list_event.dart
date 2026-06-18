part of 'task_list_bloc.dart';


abstract class TaskListEvent extends Equatable{
  const TaskListEvent();
}


class TaskListApiEvent extends TaskListEvent{
  @override
  List<Object?> get props => [];
}

class AddTaskEvent extends TaskListEvent{
  final String title;
  // final bool completed;
  const AddTaskEvent(this.title,);
  @override
  List<Object?> get props => [title,];
}

/// UPDATE TASK (IMPORTANT CHANGE)
class UpdateTaskEvent extends TaskListEvent {
  final String localId;   // ✅ CHANGED from id
  final bool completed;

  const UpdateTaskEvent(this.localId, this.completed);

  @override
  List<Object?> get props => [localId, completed];
}