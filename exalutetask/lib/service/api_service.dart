import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exalutetask/data/api/add_task_response.dart';
import 'package:exalutetask/data/api/task_list_response.dart';

import '../util/app_url.dart';

class ApiService {

  Future<TaskListResponse?> getTasks() async {


    try {
      Dio dio = Dio();

      var response = await dio.get(
        AppUrls.baseUrl + AppUrls.taskListUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          validateStatus: (status) => true,
        ),
      );

      log("RESPONSE>>> ${response.data}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return TaskListResponse.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return TaskListResponse(
          tasks: [],
          code: 401,
        );
      } else {
        return TaskListResponse(
          tasks: [],
          code: 500,
        );
      }
    } catch (e,stackTrace) {
      log("ERROR > ${e.toString()}");
      log("ERROR > $stackTrace");

      if (e.toString().contains("SocketException") ||
          e.toString().contains("Failed host lookup")) {
        return TaskListResponse(
          tasks: [],
          code: 503,
        );
      }

      return TaskListResponse(
        tasks: [],
        code: 500,
      );
    }
  }

  Future<AddTaskResponse?> addTask(String title) async {
    try {
      Dio dio = Dio();

      var response = await dio.post(
        AppUrls.baseUrl + AppUrls.taskListUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          validateStatus: (status) => true,
        ),
        data: {
          "title": title,
        },
      );
      log("RESPONSE ADD>>> ${response.data}");
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return AddTaskResponse.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return AddTaskResponse(
          createdAt: 0,
          title: "",
          completed: false,
          id: "",
          code: 401,
        );
      } else {
        return AddTaskResponse(
          createdAt: 0,
          title: "",
          completed: false,
          id: "",
          code: 500,
        );
      }
    } catch (e, stackTrace) {
      log("ERROR > $e");
      log("ERROR > $stackTrace");

      return AddTaskResponse(
        createdAt: 0,
        title: "",
        completed: false,
        id: "",
        code: 503,
      );
    }
  }

  Future<AddTaskResponse?> updateTask(String id,bool completed) async {
    try {
      Dio dio = Dio();

      var response = await dio.put(
       "${AppUrls.baseUrl}${AppUrls.taskListUrl}/$id",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          validateStatus: (status) => true,
        ),
        data: {
          "completed": completed,
        },
      );
      log("UPDATE RESPONSE>>> ${response.data}");
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return AddTaskResponse.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return AddTaskResponse(
          createdAt: 0,
          title: "",
          completed: false,
          id: "",
          code: 401,
        );
      } else {
        return AddTaskResponse(
          createdAt: 0,
          title: "",
          completed: false,
          id: "",
          code: 500,
        );
      }
    } catch (e, stackTrace) {
      log("ERROR > $e");
      log("ERROR > $stackTrace");

      return AddTaskResponse(
        createdAt: 0,
        title: "",
        completed: false,
        id: "",
        code: 503,
      );
    }
  }


}