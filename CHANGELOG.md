# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project follows Semantic Versioning.

---

## [2.0.0] - 2026-01-24

### 🚀 Major Release — Complete Modern Rewrite

This release is a full modernization of sql_conn, rebuilt for production-grade usage.

### Added
- Pigeon-based type-safe Flutter ↔ Android communication
- Multi-database support:
  - Microsoft SQL Server
  - PostgreSQL
  - MySQL / MariaDB
  - Oracle
  - Custom JDBC URLs
- Multi-connection support via `connectionId`
- Prepared statements with parameterized queries
- Stored procedure execution support
- SQL script / batch execution support
- Connection pooling using HikariCP
- SSL support enabled by default
- Null-safe Dart API (Dart 3 / Flutter 3)
- Android-only lightweight example app
- Modern Android toolchain (AGP 8+, Kotlin 1.9, Java 17 target)

### Changed
- Migrated from MethodChannel to Pigeon
- Replaced deprecated jTDS driver with official database drivers
- Complete rewrite of Android plugin architecture
- Simplified stateless Flutter API design
- Updated build system and Gradle configuration

### Removed
- Legacy MethodChannel implementation
- Deprecated jTDS SQL Server driver
- Old Android threading and StrictMode hacks
- Manual JSON string construction logic

### Security
- Default SSL-enabled database connections
- Prepared statements to prevent SQL injection
- No credential logging

---

## [0.0.3] - 2022-01-10

### Added
- Timeout support for database connections

### Fixed
- Minor bug fixes and stability improvements

---

## [0.0.2] - 2021-12-20

### Added
- Initial documentation

---

## [0.0.1] - 2021-12-01

### Added
- Initial release
- Basic SQL Server connectivity
- Read / write query support

---
