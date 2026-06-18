import 'package:exalutetask/ui/pages/task_list_page/task_list_page.dart';
import 'package:flutter/material.dart';

import 'db/database_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await DatabaseHelper.resetDb(); // Uncomment if you need to reset the DB for testing

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskListPage()
    );
  }
}
