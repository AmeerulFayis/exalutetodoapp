import 'dart:developer';

import 'package:exalutetask/db/model_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../service/netwrok_service.dart';
import 'bloc/task_list_bloc.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TextEditingController titleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final taskListBloc = TaskListBloc();

  @override
  void initState() {
    // initial load
    taskListBloc.add(TaskListApiEvent());

    // 🔥 listen network changes
    NetworkService.listen((isOnline) {
      if (isOnline) {
        taskListBloc.add(TaskListApiEvent());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    NetworkService.dispose();
    super.dispose();
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncFailed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case SyncStatus.offline:
        return "Offline";
      case SyncStatus.syncing:
        return "Syncing";
      case SyncStatus.synced:
        return "Synced";
      case SyncStatus.syncFailed:
        return "Sync Failed";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => taskListBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Task List"),
          // actions: [
          //   IconButton(
          //     onPressed: () => taskListBloc.add(TaskListApiEvent()),
          //     icon: const Icon(Icons.sync),
          //   )
          // ],
        ),
        body: BlocConsumer<TaskListBloc, TaskListState>(
          listener: (context, state) {

            if (state is AddTaskListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            List<LocalTask> tasks = [];

            if (state is TaskListLoaded) {
              tasks = state.tasks;
            }

            if (tasks.isEmpty && state is TaskListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tasks.isEmpty) {
              return const Center(child: Text("No tasks found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                bool completed = task.completed;
                int timestamp = task.createdAt;

                return InkWell(
                  onTap: () {
                    if (!completed) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Update Task"),
                          content: const Text("Mark as completed?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                taskListBloc.add(UpdateTaskEvent(task.localId, true));
                              },
                              child: const Text("Update"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: completed ? Colors.green : Colors.grey,
                            child: Icon(
                              completed ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  completed ? "Completed" : "Not Completed",
                                  style: TextStyle(
                                    color: completed ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      timestamp * 1000,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.syncStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(task.syncStatus).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add Task",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: "Task Title",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter task title";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              taskListBloc.add(
                                AddTaskEvent(
                                  titleController.text.trim(),
                                ),
                              );
                              Navigator.pop(context);
                              titleController.clear();
                            }
                          },
                          child: const Text("Add Task"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
