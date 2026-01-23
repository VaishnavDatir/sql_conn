import 'package:pigeon/pigeon.dart';

enum DatabaseType { sqlServer, postgres, mysql, oracle, custom }

class SqlConnectionConfig {
  String connectionId;
  DatabaseType dbType;

  String host;
  int port;
  String database;

  String username;
  String password;

  bool ssl;
  bool trustServerCertificate;

  int? maxPoolSize;
  int? connectionTimeoutMs;

  String? customJdbcUrl;

  SqlConnectionConfig({
    required this.connectionId,
    required this.dbType,
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.ssl = true,
    this.trustServerCertificate = true,
    this.maxPoolSize = 3,
    this.connectionTimeoutMs = 5000,
    this.customJdbcUrl,
  });
}

@HostApi()
abstract class SqlConnHostApi {
  @async
  bool connect(SqlConnectionConfig config);

  @async
  bool disconnect(String connectionId);

  @async
  List<Map<Object?, Object?>> read(
    String connectionId,
    String query,
    List<Object?>? params,
  );

  @async
  int write(
    String connectionId,
    String query,
    List<Object?>? params,
  );

  @async
  List<Map<Object?, Object?>> callProcedure(
    String connectionId,
    String procedureName,
    List<Object?>? params,
  );

  @async
  bool executeScript(
    String connectionId,
    String script,
  );
}
