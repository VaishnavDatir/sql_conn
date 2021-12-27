# sql_conn

A sql_conn is a plugin for connecting Flutter Android application to SQL Server.

This library aims to provide an easy to use interface to SQL Server.
Easily read data from SQL Database. Perform CURD as well as many other operation on database using this plugin.

## Platform Support

| Android | iOS |
| :-----: | :-: |
|   ✔️    | ❌️ |

## Usage

Connect to the database

```dart
await SqlConn.connect(
        ip: "192.168.167.176",
        port: "1433",
        databaseName: "MyDatabase",
        username: "admin123",
        password: "Pass@123");
```

Execute a query with parameters:

To read data from database

```dart
var res = await SqlConn.readData("SELECT * FROM tableName");
    print(res.toString());
    // results are in list in json format
```

To edit database (Queries such as Insert, Delete, Create and many more)

```dart
 var res = await SqlConn.writeData(query);
    print(res.toString());
    // returns true is executed successfully
```

Disconnect from database

```dart
 SqlConn.disconnect();
```

To check if application is connected to database

```dart
 print(SqlConn.isConnected);
```

### Bugs/Requests
    The plugin is still in development and there might be some bugs.
    If you encounter any problems feel free to open an issue.
    If you feel the library is missing a feature, please raise a ticket on Github.
    Pull request are also welcome.
