package com.batteryhealth.battery_health_monitor

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.batteryhealth.monitor/battery_extra"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryExtraStats") {
                val stats = getBatteryExtraStats()
                result.success(stats)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryExtraStats(): Map<String, Any?> {
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus: Intent? = context.registerReceiver(null, intentFilter)

        val stats = mutableMapOf<String, Any?>()

        if (batteryStatus != null) {
            // Temperature is in tenths of a degree Celsius (e.g. 365 = 36.5 C)
            val temp = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
            stats["temperature"] = if (temp != -1) temp / 10.0 else null

            // Voltage in millivolts (e.g. 4120 mV = 4.12 V)
            val voltage = batteryStatus.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
            stats["voltage"] = if (voltage != -1) voltage / 1000.0 else null

            // Technology (e.g. Li-ion)
            val tech = batteryStatus.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY)
            stats["technology"] = tech ?: "Unknown"

            // Coarse system health flag
            val health = batteryStatus.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN)
            val healthString = when (health) {
                BatteryManager.BATTERY_HEALTH_GOOD -> "GOOD"
                BatteryManager.BATTERY_HEALTH_OVERHEAT -> "OVERHEAT"
                BatteryManager.BATTERY_HEALTH_DEAD -> "DEAD"
                BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "OVER VOLTAGE"
                BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "UNSPECIFIED FAILURE"
                BatteryManager.BATTERY_HEALTH_COLD -> "COLD"
                else -> "UNKNOWN"
            }
            stats["healthFlag"] = healthString
        } else {
            stats["temperature"] = null
            stats["voltage"] = null
            stats["technology"] = "Unknown"
            stats["healthFlag"] = "UNKNOWN"
        }

        return stats
    }
}
