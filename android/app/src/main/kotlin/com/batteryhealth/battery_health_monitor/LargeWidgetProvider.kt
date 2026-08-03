package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class LargeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_large_4x2)

                var level = widgetData.getInt("battery_level", -1)
                var status = widgetData.getString("battery_status", null)
                var temp = widgetData.getString("battery_temp", null)
                var badge = widgetData.getString("battery_badge", "Health: Estimated") ?: "Health: Estimated"
                var cycles = widgetData.getString("battery_cycles", "0.0") ?: "0.0"

                if (level == -1 || status == null || temp == null || temp == "-- °C") {
                    try {
                        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                        val batteryStatus: Intent? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            context.registerReceiver(null, filter, Context.RECEIVER_NOT_EXPORTED)
                        } else {
                            context.registerReceiver(null, filter)
                        }
                        if (batteryStatus != null) {
                            val rawLevel = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                            val scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                            if (rawLevel != -1 && scale != -1) {
                                level = (rawLevel * 100 / scale.toFloat()).toInt()
                            }
                            val statusInt = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                            status = when (statusInt) {
                                BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
                                BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
                                BatteryManager.BATTERY_STATUS_FULL -> "Full"
                                else -> "Discharging"
                            }
                            val rawTemp = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                            if (rawTemp != -1) {
                                temp = "${rawTemp / 10.0} °C"
                            }
                        }
                    } catch (e: Throwable) {
                        Log.e("LargeWidgetProvider", "Error reading battery intent broadcast", e)
                    }
                }

                val displayLevel = if (level != -1) "$level%" else "--%"
                val displayStatus = status ?: "Discharging"
                val displayTemp = if (temp != null && temp != "-- °C") temp else "-- °C"

                views.setTextViewText(R.id.tv_large_percentage, displayLevel)
                views.setTextViewText(R.id.tv_large_status, "Status: $displayStatus")
                views.setTextViewText(R.id.tv_large_temp, displayTemp)
                views.setTextViewText(R.id.tv_large_badge, badge)
                views.setTextViewText(R.id.tv_large_cycles, cycles)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Throwable) {
                Log.e("LargeWidgetProvider", "Error updating LargeWidgetProvider", e)
            }
        }
    }
}
