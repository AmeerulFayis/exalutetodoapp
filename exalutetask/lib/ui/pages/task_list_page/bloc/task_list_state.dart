part of 'task_list_bloc.dart';


abstract class TaskListState extends Equatable{
  const TaskListState();
}

 class TaskListInitial extends TaskListState {
  @override
  List<Object?> get props =>[];
}


class TaskListLoading extends TaskListState {
  @override
  List<Object?> get props =>[];
}


class TaskListLoaded extends TaskListState {
  final List<LocalTask> tasks;
  const TaskListLoaded({
    required this.tasks,
  });
  @override
  List<Object?> get props =>[tasks];
}


class TaskListError extends TaskListState {
  final String errorMessage;
   const TaskListError(this.errorMessage);
  @override
  List<Object?> get props =>[errorMessage];
}


class TaskListNoInternet extends TaskListState {
  @override
  List<Object?> get props =>[];
}

class AddTaskListLoaded extends TaskListState {
  @override
  List<Object?> get props =>[];
}

class AddTaskListError extends TaskListState {
  final String message;
  const AddTaskListError(this.message);
  @override
  List<Object?> get props =>[message];
}

