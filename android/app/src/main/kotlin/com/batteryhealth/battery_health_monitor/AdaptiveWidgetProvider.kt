package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AdaptiveWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            updateAdaptiveWidget(context, appWidgetManager, appWidgetId, options, widgetData)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        val widgetData = context.getSharedPreferences("${context.packageName}_preferences", Context.MODE_PRIVATE)
        updateAdaptiveWidget(context, appWidgetManager, appWidgetId, newOptions, widgetData)
    }

    private fun updateAdaptiveWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        options: Bundle,
        widgetData: android.content.SharedPreferences
    ) {
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 60)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 60)

        val level = widgetData.getInt("battery_level", 0)
        val status = widgetData.getString("battery_status", "Unknown") ?: "Unknown"
        val temp = widgetData.getString("battery_temp", "-- °C") ?: "-- °C"
        val badge = widgetData.getString("battery_badge", "Health: Estimated") ?: "Health: Estimated"
        val cycles = widgetData.getString("battery_cycles", "0.0") ?: "0.0"

        val views: RemoteViews

        if (minWidth >= 250 && minHeight >= 110) {
            // Large Breakpoint
            views = RemoteViews(context.packageName, R.layout.widget_large_4x2)
            views.setTextViewText(R.id.tv_large_percentage, "$level%")
            views.setTextViewText(R.id.tv_large_status, "Status: $status")
            views.setTextViewText(R.id.tv_large_temp, temp)
            views.setTextViewText(R.id.tv_large_badge, badge)
            views.setTextViewText(R.id.tv_large_cycles, cycles)
        } else if (minWidth >= 130) {
            // Medium Breakpoint
            views = RemoteViews(context.packageName, R.layout.widget_medium_2x1)
            views.setTextViewText(R.id.tv_medium_percentage, "$level%")
            views.setTextViewText(R.id.tv_medium_status, status)
            views.setTextViewText(R.id.tv_medium_temp, "Temp: $temp")
        } else {
            // Small Breakpoint
            views = RemoteViews(context.packageName, R.layout.widget_small_1x1)
            views.setTextViewText(R.id.tv_battery_percentage, "$level%")
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
