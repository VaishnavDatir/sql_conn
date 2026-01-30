package plugin.sqlconn.sql_conn

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.sql.Connection
import java.sql.ResultSet

class SqlConnHostApiImpl : SqlConnHostApi {

    private val configs = mutableMapOf<String, SqlConnectionConfig>()
    private val scope = CoroutineScope(Dispatchers.IO)

    // ---------------- CONNECT ----------------

    override fun connect(config: SqlConnectionConfig, callback: (Result<Boolean>) -> Unit) {
    scope.launch {
        try {
            // Just test opening a connection
            val url = buildJdbcUrl(config)
            val conn = java.sql.DriverManager.getConnection(url, config.username, config.password)
            conn.close()

            // Store config for later use
            configs[config.connectionId] = config

            callback(Result.success(true))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }
}


    // ---------------- DISCONNECT ----------------

    override fun disconnect(connectionId: String, callback: (Result<Boolean>) -> Unit) {
    scope.launch {
        configs.remove(connectionId)
        callback(Result.success(true))
    }
}

    // ---------------- READ ----------------

    override fun read(
        connectionId: String,
        query: String,
        params: List<Any?>?,
        callback: (Result<List<Map<Any?, Any?>>>) -> Unit
    ) {
        scope.launch {
            try {
                val conn = getConnection(connectionId)
                val ps = conn.prepareStatement(query)
                params?.forEachIndexed { i, v -> ps.setObject(i + 1, v) }
                val rs = ps.executeQuery()
                callback(Result.success(rs.toListSafe()))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    // ---------------- WRITE ----------------

    override fun write(
        connectionId: String,
        query: String,
        params: List<Any?>?,
        callback: (Result<Long>) -> Unit
    ) {
        scope.launch {
            try {
                val conn = getConnection(connectionId)
                val ps = conn.prepareStatement(query)
                params?.forEachIndexed { i, v -> ps.setObject(i + 1, v) }
                val count = ps.executeUpdate().toLong()
                callback(Result.success(count))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    // ---------------- STORED PROCEDURE ----------------

    override fun callProcedure(
        connectionId: String,
        procedureName: String,
        params: List<Any?>?,
        callback: (Result<List<Map<Any?, Any?>>>) -> Unit
    ) {
        scope.launch {
            try {
                val conn = getConnection(connectionId)
                val syntax = "{call $procedureName(${params?.joinToString(",") { "?" } ?: ""})}"
                val cs = conn.prepareCall(syntax)
                params?.forEachIndexed { i, v -> cs.setObject(i + 1, v)
                }
                val rs = cs.executeQuery()
                callback(Result.success(rs.toListSafe()))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    // ---------------- SCRIPT ----------------

    override fun executeScript(
        connectionId: String,
        script: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        scope.launch {
            try {
                val conn = getConnection(connectionId)
                val stmt = conn.createStatement()
                script.split(";").forEach { sql ->
                    if (sql.trim().isNotEmpty()) stmt.execute(sql)
                }
                callback(Result.success(true))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    // ---------------- HELPERS ----------------

    private fun getConnection(id: String): Connection {
        val cfg = configs[id] ?: throw Exception("Connection not found: $id")
        val url = buildJdbcUrl(cfg)
        return java.sql.DriverManager.getConnection(url, cfg.username, cfg.password)
    }

    private fun buildJdbcUrl(cfg: SqlConnectionConfig): String {
    val url = "jdbc:jtds:sqlserver://${cfg.host}:${cfg.port}/${cfg.database}"
    return url
}

// ---------------- RESULTSET EXT ----------------

private fun ResultSet.toListSafe(): List<Map<Any?, Any?>> {
    val meta = metaData
    val columnCount = meta.columnCount
    val results = ArrayList<Map<Any?, Any?>>()

    while (next()) {
        val row = HashMap<Any?, Any?>()

        for (i in 1..columnCount) {
            val columnName = meta.getColumnLabel(i)  // already nullable-friendly
            val value = getObject(i)

            row[columnName] = when (value) {
                null -> null

                // Date / Time
                is java.sql.Timestamp -> value.toString()
                is java.sql.Date -> value.toString()
                is java.sql.Time -> value.toString()

                // Numeric
                is java.math.BigDecimal -> value.stripTrailingZeros().toPlainString()
                is Number -> value

                // Boolean
                is Boolean -> value

                // Binary
                is ByteArray -> value
                is java.sql.Blob -> value.binaryStream.readBytes()

                // String
                is String -> value

                // Fallback
                else -> value.toString()
            }
        }
        results.add(row)
    }
    return results
}

}