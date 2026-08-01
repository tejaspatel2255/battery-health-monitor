package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
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
            val views = RemoteViews(context.packageName, R.layout.widget_large_4x2)
            val level = widgetData.getInt("battery_level", 0)
            val status = widgetData.getString("battery_status", "Unknown") ?: "Unknown"
            val temp = widgetData.getString("battery_temp", "-- °C") ?: "-- °C"
            val badge = widgetData.getString("battery_badge", "Health: Estimated") ?: "Health: Estimated"
            val cycles = widgetData.getString("battery_cycles", "0.0") ?: "0.0"

            views.setTextViewText(R.id.tv_large_percentage, "$level%")
            views.setTextViewText(R.id.tv_large_status, "Status: $status")
            views.setTextViewText(R.id.tv_large_temp, temp)
            views.setTextViewText(R.id.tv_large_badge, badge)
            views.setTextViewText(R.id.tv_large_cycles, cycles)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
