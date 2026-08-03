package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SmallWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_small_1x1)
                var level = widgetData.getInt("battery_level", -1)
                var temp = widgetData.getString("battery_temp", null)

                if (level == -1 || temp == null || temp == "-- °C") {
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
                            val rawTemp = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                            if (rawTemp != -1) {
                                temp = "${rawTemp / 10.0} °C"
                            }
                        }
                    } catch (_: Throwable) {}
                }

                val displayLevel = if (level != -1) "$level%" else "--%"
                val displayTemp = if (temp != null && temp != "-- °C") temp else "-- °C"

                views.setTextViewText(R.id.tv_battery_percentage, displayLevel)
                views.setTextViewText(R.id.tv_battery_temp, displayTemp)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Throwable) {}
        }
    }
}
