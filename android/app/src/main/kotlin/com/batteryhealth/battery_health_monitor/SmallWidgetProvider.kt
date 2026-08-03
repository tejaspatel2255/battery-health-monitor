package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
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
            val views = RemoteViews(context.packageName, R.layout.widget_small_1x1)
            var level = widgetData.getInt("battery_level", -1)

            if (level == -1) {
                val batteryStatus: Intent? = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                if (batteryStatus != null) {
                    val rawLevel = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                    val scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                    if (rawLevel != -1 && scale != -1) {
                        level = (rawLevel * 100 / scale.toFloat()).toInt()
                    }
                }
            }

            val displayLevel = if (level != -1) level else 0
            views.setTextViewText(R.id.tv_battery_percentage, "$displayLevel%")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
