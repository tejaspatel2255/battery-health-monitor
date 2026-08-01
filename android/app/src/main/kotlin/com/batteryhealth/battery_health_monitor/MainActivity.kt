package com.batteryhealth.battery_health_monitor

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val EXTRA_CHANNEL = "com.batteryhealth.monitor/battery_extra"
    private val ROOT_CHANNEL = "com.batteryhealth.monitor/root_battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EXTRA_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryExtraStats") {
                val stats = getBatteryExtraStats()
                result.success(stats)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ROOT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkRootAvailability" -> {
                    result.success(isRootAvailable())
                }
                "getRootBatteryStats" -> {
                    val stats = getRootBatteryStats()
                    result.success(stats)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isRootAvailable(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun getRootBatteryStats(): Map<String, Any?> {
        val stats = mutableMapOf<String, Any?>()

        if (!isRootAvailable()) {
            stats["isRootAvailable"] = false
            stats["isRootGranted"] = false
            return stats
        }

        stats["isRootAvailable"] = true

        try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "cat /sys/class/power_supply/battery/charge_full /sys/class/power_supply/battery/charge_full_design /sys/class/power_supply/battery/cycle_count"))
            val exitCode = process.waitFor()

            if (exitCode == 0) {
                stats["isRootGranted"] = true
                val output = process.inputStream.bufferedReader().readLines()

                val chargeFullRaw = output.getOrNull(0)?.trim()?.toLongOrNull()
                val chargeFullDesignRaw = output.getOrNull(1)?.trim()?.toLongOrNull()
                val cycleCountRaw = output.getOrNull(2)?.trim()?.toIntOrNull()

                // OEM nodes can report mAh or uAh (microampere-hours)
                stats["chargeFull"] = chargeFullRaw
                stats["chargeFullDesign"] = chargeFullDesignRaw
                stats["cycleCount"] = cycleCountRaw
            } else {
                stats["isRootGranted"] = false
            }
        } catch (e: Exception) {
            stats["isRootGranted"] = false
        }

        return stats
    }

    private fun getBatteryExtraStats(): Map<String, Any?> {
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus: Intent? = context.registerReceiver(null, intentFilter)

        val stats = mutableMapOf<String, Any?>()

        if (batteryStatus != null) {
            val temp = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
            stats["temperature"] = if (temp != -1) temp / 10.0 else null

            val voltage = batteryStatus.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
            stats["voltage"] = if (voltage != -1) voltage / 1000.0 else null

            val tech = batteryStatus.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY)
            stats["technology"] = tech ?: "Unknown"

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
