import 'package:flutter/material.dart';
import 'package:sql_conn/sql_conn.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "sql_conn Demo", home: TestPage());
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  static const String connectionId = "mainDB";

  /// Shows a simple loading dialog
  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text("Please wait"),
        content: SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  /// Hides loading dialog
  void _hideLoader() {
    Navigator.of(context).pop();
  }

  /// Connect to database
  Future<void> connect() async {
    debugPrint("Connecting...");

    _showLoader();
    try {
      await SqlConn.connect(
        connectionId: connectionId,
        host: "192.168.29.46", // <-- change
        port: 1433,
        database: "FLUTTER_TEST_DEV", // <-- change
        username: "SA", // <-- change
        password: "Admin@123", // <-- change
        ssl: false,
        trustServerCertificate: false,
      );

      debugPrint("Connected Successfully!");
      _showMessage("Connected Successfully!");
    } catch (e) {
      debugPrint("Connection Error: $e");
      _showMessage("Connection Failed!\n$e");
    } finally {
      _hideLoader();
    }
  }

  /// Read data
  Future<void> readData() async {
    try {
      final res = await SqlConn.read(connectionId, "SELECT * FROM T_USERS ");

      debugPrint("Read Result: $res");
      _showMessage("Read Success!\n$res");
      _showUsersPopup(res);
    } catch (e) {
      debugPrint("Read Error: $e");
      _showMessage("Read Failed!\n$e");
    }
  }

  /// Execute write / delete / create queries
  Future<void> writeData(String query, List<Object?>? params) async {
    try {
      final res = await SqlConn.write(connectionId, query, params: params);
      debugPrint("Write Result: $res rows affected");
      _showMessage("Write Success!\nRows affected: $res");
    } catch (e) {
      debugPrint("Write Error: $e");
      _showMessage("Write Failed!\n$e");
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    try {
      await SqlConn.disconnect(connectionId);
      debugPrint("Disconnected");
      _showMessage("Disconnected Successfully!");
    } catch (e) {
      debugPrint("Disconnect Error: $e");
      _showMessage("Disconnect Failed!\n$e");
    }
  }

  /// Simple popup message
  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showUsersPopup(List<Map<String, Object?>> users) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Users"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // makes dialog scrollable
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              final name = user["Name"]?.toString() ?? "No Name";
              final mobile = user["Mobile_Number"]?.toString() ?? "N/A";
              final active = user["IS_ACTIVE"]?.toString() ?? "N/A";

              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(name),
                subtitle: Text("📞 $mobile"),
                trailing: Text(
                  active == "Y" ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: active == "Y" ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("sql_conn Example")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: connect, child: const Text("Connect")),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: readData,
                child: const Text("Read Data"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => writeData(
                  "DELETE FROM T_USERS WHERE Mobile_Number=?",
                  [9000000002],
                ),
                child: const Text("Delete Row"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => writeData(
                  "CREATE TABLE Persons (PersonID int, LastName varchar(255), FirstName varchar(255), Address varchar(255), City varchar(255))",
                  null,
                ),
                child: const Text("Create Table"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => writeData("DROP TABLE Persons", null),
                child: const Text("Drop Table"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: disconnect,
                child: const Text("Disconnect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
