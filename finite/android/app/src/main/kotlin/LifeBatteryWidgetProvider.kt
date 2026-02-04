package com.example.finite // MAKE SURE THIS MATCHES YOUR PACKAGE NAME

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class LifeBatteryWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get the image created by Flutter
                val image = widgetData.getString("life_battery", null)
                if (image != null) {
                    setImageViewBitmap(R.id.widget_image, BitmapFactory.decodeFile(image))
                    setViewVisibility(R.id.widget_image, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.widget_image, View.GONE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}