package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MediumWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium_2x1)
            val level = widgetData.getInt("battery_level", 0)
            val status = widgetData.getString("battery_status", "Unknown") ?: "Unknown"
            val temp = widgetData.getString("battery_temp", "-- °C") ?: "-- °C"

            views.setTextViewText(R.id.tv_medium_percentage, "$level%")
            views.setTextViewText(R.id.tv_medium_status, status)
            views.setTextViewText(R.id.tv_medium_temp, "Temp: $temp")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
