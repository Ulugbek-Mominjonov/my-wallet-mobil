package uz.mywallet.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * E33-T01: bosh ekran vidjeti — joriy oy qoldig'i, "kuniga ≈ X" va "＋".
 *
 * Qiymatlarni ilova yozadi (home_widget); bu yerda faqat ko'rsatiladi.
 * Maxfiylik rejimida (BR-212) ilova summalar o'rniga "•••" yozadi.
 */
class HomeScreenWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString("title", "") ?: "")
                setTextViewText(R.id.widget_balance, widgetData.getString("balance", "—") ?: "—")
                setTextViewText(R.id.widget_per_day, widgetData.getString("per_day", "") ?: "")
                setTextViewText(R.id.widget_add, widgetData.getString("add_label", "+") ?: "+")

                // Vidjet bosilsa — ilova; "＋" — to'g'ridan-to'g'ri qo'shish varag'i.
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                setOnClickPendingIntent(
                    R.id.widget_add,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse(widgetData.getString("add_uri", "") ?: ""),
                    ),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
