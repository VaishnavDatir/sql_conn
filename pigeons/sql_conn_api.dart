import 'package:pigeon/pigeon.dart';


class SqlConnectionConfig {
  String connectionId;

  String host;
  int port;
  String database;

  String username;
  String password;


  SqlConnectionConfig({
    required this.connectionId,
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
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
