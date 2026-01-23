import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import 'src/sql_conn_api.g.dart';

/// Custom exception thrown by sql_conn when a native or connection error occurs.
class SqlConnException implements Exception {
  final String message;
  SqlConnException(this.message);

  @override
  String toString() => "SqlConnException: $message";
}

/// SqlConn provides a stateless, type-safe API to connect Flutter Android
/// applications directly to SQL databases using JDBC.
///
/// This plugin is designed for **Android-only**, internal or LAN-based
/// enterprise / industrial applications where direct database access
/// from a mobile device is required.
///
/// Supported databases:
/// - Microsoft SQL Server
/// - PostgreSQL
/// - MySQL / MariaDB
/// - Oracle
/// - Any custom JDBC-supported database
///
/// All operations are asynchronous, non-blocking, and executed using
/// connection pooling for high performance.
///
/// Example:
/// ```dart
/// await SqlConn.connect(
///   connectionId: "mainDB",
///   dbType: DatabaseType.sqlServer,
///   host: "192.168.1.10",
///   port: 1433,
///   database: "FactoryDB",
///   username: "admin",
///   password: "Pass@123",
/// );
///
/// final rows = await SqlConn.read(
///   "mainDB",
///   "SELECT * FROM users WHERE role = ?",
///   params: ["admin"],
/// );
///
/// print(rows);
/// await SqlConn.disconnect("mainDB");
/// ```
class SqlConn {
  static final SqlConnHostApi _api = SqlConnHostApi();

  /// Centralized debug logger that only runs in Debug mode
  static void _log(String message,
      {String? connectionId, Duration? elapsed, int? rows}) {
    if (kDebugMode) {
      final String timeStr =
          elapsed != null ? " | Time: ${elapsed.inMilliseconds}ms" : "";
      final String rowStr = rows != null ? " | Rows: $rows" : "";
      final String connStr = connectionId != null ? " [$connectionId]" : "";

      // Using dev.log makes it searchable in the "Logging" tab of DevTools
      dev.log(
        "SQL_CONN$connStr: $message$timeStr$rowStr",
        name: 'sql_conn',
      );
    }
  }

  /// Establishes a connection to a database and registers it
  /// internally using the provided [connectionId].
  ///
  /// Multiple databases can be connected simultaneously by using
  /// different connectionId values.
  ///
  /// Parameters:
  /// - [connectionId]: Unique identifier for this connection instance.
  /// - [dbType]: Type of database engine to connect to.
  /// - [host]: Database server host or IP address.
  /// - [port]: Database server port.
  /// - [database]: Database name or schema.
  /// - [username]: Database username.
  /// - [password]: Database password.
  /// - [ssl]: Enables SSL encryption (default: true).
  /// - [trustServerCertificate]: Enables self-signed certificates (default: true)
  /// - [customJdbcUrl]: Required only when dbType = DatabaseType.custom.
  ///
  /// Returns true if connection succeeds.
  ///
  /// Throws [SqlConnException] if connection fails.
  static Future<bool> connect({
    required String connectionId,
    required DatabaseType dbType,
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
    bool ssl = true,
    bool trustServerCertificate = true,
    int timeout = 5,
    String? customJdbcUrl,
  }) async {
    try {
      return await _api.connect(SqlConnectionConfig(
        connectionId: connectionId,
        dbType: dbType,
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
        ssl: ssl,
        trustServerCertificate: trustServerCertificate,
        customJdbcUrl: customJdbcUrl,
      ));
    } catch (e) {
      throw SqlConnException(e.toString());
    }
  }

  /// Closes and removes a previously opened connection.
  ///
  /// After disconnecting, the [connectionId] becomes invalid
  /// and must be reconnected before further queries.
  ///
  /// Returns true if successfully disconnected.
  ///
  /// Throws [SqlConnException] if disconnect fails.
  static Future<bool> disconnect(String connectionId) async {
    try {
      return await _api.disconnect(connectionId);
    } catch (e) {
      throw SqlConnException(e.toString());
    }
  }

  /// Executes a SELECT query and returns the result as a
  /// List of Map<String, Object?>.
  ///
  /// Each row is represented as a Map where:
  /// - Key = column name
  /// - Value = column value
  ///
  /// Supports parameterized queries using '?' placeholders.
  ///
  /// Example:
  /// ```dart
  /// final rows = await SqlConn.read(
  ///   "mainDB",
  ///   "SELECT * FROM users WHERE id = ? AND active = ?",
  ///   params: [101, true],
  /// );
  /// ```
  ///
  /// Throws [SqlConnException] if query execution fails.
  static Future<List<Map<String, Object?>>> read(
    String connectionId,
    String query, {
    List<Object?>? params,
  }) async {
    final sw = Stopwatch()..start(); 
    try {
      final res = await _api.read(connectionId, query, params);

      final results = res.map((row) {
        final clean = <String, Object?>{};
        row.forEach((k, v) => clean[k.toString()] = v);
        return clean;
      }).toList();

      sw.stop();

      _log("READ SUCCESS",
          connectionId: connectionId,
          elapsed: sw.elapsed,
          rows: results.length);

      return results;
    } catch (e) {
      sw.stop();
      _log("READ ERROR: $e", connectionId: connectionId, elapsed: sw.elapsed);
      throw SqlConnException(e.toString());
    }
  }

  /// Executes INSERT, UPDATE, DELETE, or DDL queries.
  ///
  /// Returns the number of affected rows.
  ///
  /// Example:
  /// ```dart
  /// final count = await SqlConn.write(
  ///   "mainDB",
  ///   "UPDATE users SET active = ? WHERE id = ?",
  ///   params: [true, 101],
  /// );
  /// print("Rows updated: $count");
  /// ```
  ///
  /// Throws [SqlConnException] if execution fails.
  static Future<int> write(
    String connectionId,
    String query, {
    List<Object?>? params,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final count = await _api.write(connectionId, query, params);
      sw.stop();

      _log("WRITE SUCCESS",
          connectionId: connectionId, elapsed: sw.elapsed, rows: count.toInt());

      return count.toInt();
    } catch (e) {
      sw.stop();
      _log("WRITE ERROR: $e", connectionId: connectionId, elapsed: sw.elapsed);
      throw SqlConnException(e.toString());
    }
  }

  /// Executes a stored procedure and returns the result set.
  ///
  /// Example:
  /// ```dart
  /// final result = await SqlConn.callProcedure(
  ///   "mainDB",
  ///   "sp_generate_report",
  ///   params: [2026, "JAN"],
  /// );
  /// ```
  ///
  /// Throws [SqlConnException] if execution fails.
  static Future<List<Map<String, Object?>>> callProcedure(
    String connectionId,
    String procedureName, {
    List<Object?>? params,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final res = await _api.callProcedure(connectionId, procedureName, params);

      final results = res.map<Map<String, Object?>>((row) {
        final map = <String, Object?>{};
        row.forEach((key, value) {
          map[key.toString()] = value;
        });
        return map;
      }).toList();

      sw.stop();

      _log("Call Procedure SUCCESS",
          connectionId: connectionId,
          elapsed: sw.elapsed,
          rows: results.length);

      return results;
    } catch (e) {
      sw.stop();
      _log("Call Procedure ERROR: $e",
          connectionId: connectionId, elapsed: sw.elapsed);
      throw SqlConnException(e.toString());
    }
  }

  /// Executes a multi-statement SQL script.
  ///
  /// Useful for:
  /// - Creating tables
  /// - Creating triggers
  /// - Schema migrations
  /// - Batch execution
  ///
  /// Example:
  /// ```dart
  /// await SqlConn.executeScript(
  ///   "mainDB",
  ///   """
  ///   CREATE TABLE logs(id INT, message VARCHAR(255));
  ///   CREATE INDEX idx_logs ON logs(id);
  ///   """,
  /// );
  /// ```
  ///
  /// Returns true if script executes successfully.
  ///
  /// Throws [SqlConnException] if execution fails.
  static Future<bool> executeScript(
    String connectionId,
    String script,
  ) async {
    try {
      return await _api.executeScript(connectionId, script);
    } catch (e) {
      throw SqlConnException(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience helper for the most common use-case (SQL Server)
  // ---------------------------------------------------------------------------

  /// Quick helper to connect to Microsoft SQL Server without specifying dbType.
  ///
  /// Example:
  /// ```dart
  /// await SqlConn.connectSqlServer(
  ///   connectionId: "mainDB",
  ///   host: "192.168.1.10",
  ///   port: 1433,
  ///   database: "FactoryDB",
  ///   username: "admin",
  ///   password: "Pass@123",
  /// );
  /// ```
  static Future<bool> connectSqlServer({
    required String connectionId,
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
    bool ssl = true,
  }) {
    return connect(
      connectionId: connectionId,
      dbType: DatabaseType.sqlServer,
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      ssl: ssl,
    );
  }
}
