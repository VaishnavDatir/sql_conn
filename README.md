# sql_conn

**sql_conn** is a production-ready Flutter plugin that allows **Android applications** to connect directly to SQL databases using JDBC with connection pooling.

It provides a clean, type-safe, null-safe Dart API powered by **Pigeon**, and a high-performance Android backend using **HikariCP**.

This plugin is designed for **LAN / internal network / enterprise / industrial** use-cases where direct database connectivity from a mobile device is required.

---

## ✨ Features

- Android-only direct SQL connectivity
- Multi-database support:
  - Microsoft SQL Server
  - PostgreSQL
  - MySQL / MariaDB
  - Oracle
  - Custom JDBC URLs
- Multiple simultaneous database connections
- Connection pooling (HikariCP)
- Prepared statements (parameterized queries)
- Stored procedure execution
- SQL script / batch execution
- SSL-enabled connections by default
- Fully null-safe Dart API
- Type-safe Flutter ↔ Android bridge using Pigeon

---

## 📱 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅ Yes |
| iOS      | 🚧 Under construction |
| Web      | 💭 Planning |
| Windows  | 🚫 No |
| MacOs    | 🚫 No |


> Direct database connections from mobile apps should only be used in trusted or internal networks.

---

## 🚀 Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  sql_conn: ^2.0.0
```

---

## ⚙️ Basic Usage
### Connect to a database
```dart
await SqlConn.connect(
  connectionId: "mainDB",
  dbType: DatabaseType.sqlServer,
  host: "192.168.1.10",
  port: 1433,
  database: "MyDatabase",
  username: "admin",
  password: "Password@123",
);
```

### Read data
```dart
final rows = await SqlConn.read(
  "mainDB",
  "SELECT * FROM users WHERE role = ?",
  params: ["admin"],
);

print(rows);
```

### Write / Update / Delete

```dart
final count = await SqlConn.write(
  "mainDB",
  "UPDATE users SET active = ? WHERE id = ?",
  params: [true, 101],
);

print("Rows affected: $count");
```

### Call Stored Procedure
```dart
final result = await SqlConn.callProcedure(
  "mainDB",
  "sp_generate_report",
  params: [2026, "JAN"],
);
```

### Execute SQL Script
```dart
await SqlConn.executeScript(
  "mainDB",
  """
  CREATE TABLE logs(id INT, message VARCHAR(255));
  CREATE INDEX idx_logs ON logs(id);
  """,
);
```

### Disconnect
```dart
await SqlConn.disconnect("mainDB");
```

### 🧩 Multiple Connections
```dart
await SqlConn.connect(connectionId: "db1", dbType: DatabaseType.sqlServer, ...);
await SqlConn.connect(connectionId: "db2", dbType: DatabaseType.postgres, ...);

final a = await SqlConn.read("db1", "SELECT * FROM table1");
final b = await SqlConn.read("db2", "SELECT * FROM table2");
```

### 🔧 Custom JDBC URL
```dart
await SqlConn.connect(
  connectionId: "legacy",
  dbType: DatabaseType.custom,
  host: "",
  port: 0,
  database: "",
  username: "sysdba",
  password: "masterkey",
  customJdbcUrl: "jdbc:firebirdsql://192.168.1.9/employee",
);
```

---

## 🧠 State Management

**sql_conn** is a stateless service API.
You can integrate it with any state manager:
- Provider
- Riverpod
- Bloc
- GetX
- Service Locators
- Connection lifecycle is fully controlled by your app.

---

## ⚡ Performance
- HikariCP connection pooling
- Prepared statement reuse
- Non-blocking platform channel
- Minimal memory overhead

---

## 🔐 Security
- SSL enabled by default
- Prepared statements prevent SQL injection
- No credential logging