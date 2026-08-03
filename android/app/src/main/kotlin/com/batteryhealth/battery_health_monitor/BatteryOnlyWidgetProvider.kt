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

class BatteryOnlyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_battery_only_1x1)
                var level = widgetData.getInt("battery_level", -1)

                if (level == -1) {
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
                        }
                    } catch (e: Throwable) {
                        Log.e("BatteryOnlyWidgetProvider", "Error reading battery intent broadcast", e)
                    }
                }

                val displayLevel = if (level != -1) "$level%" else "--%"

                views.setTextViewText(R.id.tv_battery_only_percentage, displayLevel)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Throwable) {
                Log.e("BatteryOnlyWidgetProvider", "Error updating BatteryOnlyWidgetProvider", e)
            }
        }
    }
}
