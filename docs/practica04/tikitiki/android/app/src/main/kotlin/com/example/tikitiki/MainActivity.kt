package com.example.tikitiki

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingSeason: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.tikitiki/season_launcher")
            .setMethodCallHandler { call, result ->
                if (call.method == "setSeason") {
                    // Deshabilitar el alias que abrió esta Activity provoca que
                    // Android cierre la pantalla incluso con DONT_KILL_APP.
                    // Actualizar al pasar a segundo plano evita interrumpirla.
                    pendingSeason = call.arguments as? String ?: "normal"
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onStop() {
        super.onStop()
        val season = pendingSeason ?: return
        pendingSeason = null
        setSeasonLauncher(season)
    }

    private fun setSeasonLauncher(season: String) {
        val names = mapOf(
            "normal" to "LauncherNormal",
            "halloween" to "LauncherHalloween",
            "christmas" to "LauncherChristmas",
            "valentines" to "LauncherValentines",
        )
        val targetName = names[season] ?: names.getValue("normal")

        // Habilitar primero evita que algunos launchers vean por un instante
        // a la aplicación sin ningún componente LAUNCHER activo.
        setLauncherEnabled(targetName, true)

        names.values.filter { it != targetName }.forEach { name ->
            setLauncherEnabled(name, false)
        }
    }

    private fun setLauncherEnabled(name: String, enabled: Boolean) {
        val component = ComponentName(this, "$packageName.$name")
        val desiredState = if (enabled) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        } else {
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }
        if (packageManager.getComponentEnabledSetting(component) != desiredState) {
            packageManager.setComponentEnabledSetting(
                component, desiredState, PackageManager.DONT_KILL_APP,
            )
        }
    }
}
