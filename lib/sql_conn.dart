import 'dart:async';

import 'package:flutter/services.dart';

class SqlConn {
  static const MethodChannel _channel =
      MethodChannel('plugin.sqlconn.sql_conn/sql_conn');

  static bool _isConnected = false;

  static bool get isConnected => _isConnected;

  static Future connect({
    required String ip,
    required String port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> args = {
      "ip": ip,
      "port": port,
      "databaseName": databaseName,
      "username": username,
      "password": password
    };
    try {
      _isConnected = await _channel.invokeMethod("connectDB", args);
    } catch (error) {
      rethrow;
    }
  }

  static Future readData(String query) async {
    Map<String, dynamic> args = {
      "query": query,
    };
    try {
      return await _channel.invokeMethod("readData", args);
    } catch (error) {
      rethrow;
    }
  }

  static Future writeData(String query) async {
    Map<String, dynamic> args = {
      "query": query,
    };
    try {
      return await _channel.invokeMethod("writeData", args);
    } catch (error) {
      rethrow;
    }
  }

  static Future disconnect() async {
    try {
      _isConnected = await _channel.invokeMethod("disconnectDB");
    } catch (error) {
      rethrow;
    }
  }
}
