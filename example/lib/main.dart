import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sql_conn/sql_conn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> connect() async {
    await SqlConn.connect(
        ip: "192.168.167.176",
        port: "1433",
        databaseName: "MDCData",
        username: "AS",
        password: "112233");
  }

  Future<void> read(String query) async {
    var res = await SqlConn.readData(query);
    print(res.toString());
  }

  Future<void> write(String query) async {
    var res = await SqlConn.writeData(query);
    print(res.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => connect(), child: const Text("Connect")),
                ElevatedButton(
                    onPressed: () => read("SELECT * FROM IP_List"), child: const Text("Read")),
                ElevatedButton(
                    onPressed: () => write("DELETE FROM IP_List WHERE LOC='vv1'"), child: const Text("Write")),
                ElevatedButton(
                    onPressed: () => SqlConn.disconnect(), child: const Text("Disconnect"))
              ],
            ),
          )),
    );
  }
}
