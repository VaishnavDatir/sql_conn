import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sql_conn/sql_conn.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugin.sqlconn.sql_conn/sql_conn');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('readData', () async {
    expect(await SqlConn.readData("SELECT * FROM IP_List"), '42');
  });
}
