package com.batteryhealth.battery_health_monitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
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

        var level = widgetData.getInt("battery_level", -1)
        var status = widgetData.getString("battery_status", null)
        var temp = widgetData.getString("battery_temp", null)
        val badge = widgetData.getString("battery_badge", "Health: Estimated") ?: "Health: Estimated"
        val cycles = widgetData.getString("battery_cycles", "0.0") ?: "0.0"

        if (level == -1 || status == null || temp == null || temp == "-- °C") {
            val batteryStatus: Intent? = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
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
        }

        val displayLevel = if (level != -1) "$level%" else "--%"
        val displayStatus = status ?: "Discharging"
        val displayTemp = if (temp != null && temp != "-- °C") temp else "-- °C"

        val views: RemoteViews

        if (minWidth >= 250 && minHeight >= 110) {
            views = RemoteViews(context.packageName, R.layout.widget_large_4x2)
            views.setTextViewText(R.id.tv_large_percentage, displayLevel)
            views.setTextViewText(R.id.tv_large_status, "Status: $displayStatus")
            views.setTextViewText(R.id.tv_large_temp, displayTemp)
            views.setTextViewText(R.id.tv_large_badge, badge)
            views.setTextViewText(R.id.tv_large_cycles, cycles)
        } else if (minWidth >= 130) {
            views = RemoteViews(context.packageName, R.layout.widget_medium_2x1)
            views.setTextViewText(R.id.tv_medium_percentage, displayLevel)
            views.setTextViewText(R.id.tv_medium_status, displayStatus)
            views.setTextViewText(R.id.tv_medium_temp, "Temp: $displayTemp")
        } else {
            views = RemoteViews(context.packageName, R.layout.widget_small_1x1)
            views.setTextViewText(R.id.tv_battery_percentage, displayLevel)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
