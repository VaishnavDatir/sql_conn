package plugin.sqlconn.sql_conn

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

class SqlConnPlugin : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        SqlConnHostApi.setUp(
            binding.binaryMessenger,
            SqlConnHostApiImpl()
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}
}
