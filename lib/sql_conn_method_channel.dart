import 'package:flutter/services.dart';

/// An implementation of [SqlConnPlatform] that uses method channels.
class MethodChannelSqlConn {
  /// The method channel used to interact with the native platform.
  final _methodChannel =
      const MethodChannel('plugin.sqlconn.sql_conn/sql_conn');

  Future<bool> connectToDB(Map<String, dynamic> args) async {
    return await _methodChannel.invokeMethod("connectDB", args);
  }

  Future<String> readDataFromDB(Map<String, dynamic> args) async {
    return await _methodChannel.invokeMethod("readData", args);
  }

  Future<bool> writeDataToDB(Map<String, dynamic> args) async {
    return await _methodChannel.invokeMethod("writeData", args);
  }

  Future<bool> disconnectFromDB() async {
    return await _methodChannel.invokeMethod("disconnectDB");
  }
}
