package com.example.finite

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

// Changed Class Name
class QuoteWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // CHANGED KEY: "quote_widget" matches main.dart
                val image = widgetData.getString("quote_widget", null)
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