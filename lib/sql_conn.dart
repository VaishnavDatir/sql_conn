import 'dart:async';

import 'package:flutter/services.dart';

class SqlConn {
  static const MethodChannel _channel =
      MethodChannel('plugin.sqlconn.sql_conn/sql_conn');

  static bool _isConnected = false;

  /// To check if application is connected with database
  static bool get isConnected => _isConnected;

  /// To connect to the database
  ///
  /// The arguments [ip], [port], [databaseName],
  /// [username], and [password] must not be null.
  ///
  /// If [username] or [password] are empty just
  /// pass the empty string.
  /// [timeout] The timeout for connecting to the database and for all database operations.
  /// Accept only int value of seconds
  /// By default it is 15 seconds
  static Future connect({
    required String ip,
    required String port,
    required String databaseName,
    required String username,
    required String password,
    int timeout = 15,
  }) async {
    Map<String, dynamic> args = {
      "ip": ip,
      "port": port,
      "databaseName": databaseName,
      "username": username,
      "password": password,
      "timeout":timeout,
    };
    try {
      _isConnected = await _channel.invokeMethod("connectDB", args);
    } catch (error) {
      rethrow;
    }
  }

  /// To read the data from the database.
  ///
  /// The argument [query] must not be null.
  /// The response is in json list format
  /// and can be decoded using json.decode().
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

  /// To write the data in the database.
  ///
  /// The argument [query] must not be null.
  /// The response is true if query is executed successfully.
  /// Else the error is thrown
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

  /// To disconnect form the database.
  static Future disconnect() async {
    try {
      _isConnected = await _channel.invokeMethod("disconnectDB");
    } catch (error) {
      rethrow;
    }
  }
}
