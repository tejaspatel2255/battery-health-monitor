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

class TempOnlyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_temp_only_1x1)
                var temp = widgetData.getString("battery_temp", null)

                if (temp == null || temp == "-- °C") {
                    try {
                        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                        val batteryStatus: Intent? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            context.registerReceiver(null, filter, Context.RECEIVER_NOT_EXPORTED)
                        } else {
                            context.registerReceiver(null, filter)
                        }
                        if (batteryStatus != null) {
                            val rawTemp = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                            if (rawTemp != -1) {
                                temp = "${rawTemp / 10.0} °C"
                            }
                        }
                    } catch (e: Throwable) {
                        Log.e("TempOnlyWidgetProvider", "Error reading battery intent broadcast", e)
                    }
                }

                val displayTemp = if (temp != null && temp != "-- °C") temp else "-- °C"

                views.setTextViewText(R.id.tv_temp_only_val, displayTemp)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Throwable) {
                Log.e("TempOnlyWidgetProvider", "Error updating TempOnlyWidgetProvider", e)
            }
        }
    }
}
