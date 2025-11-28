package com.fetchpet.fetch_pet_widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * 뽑기펫 홈 화면 위젯 Provider
 */
class FetchPetWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // 첫 번째 위젯이 생성될 때 호출
    }

    override fun onDisabled(context: Context) {
        // 마지막 위젯이 삭제될 때 호출
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPrefs"
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.fetch_pet_widget)

            // 데이터 로드
            val state = widgetData.getString("widget_state", "waiting")
            val message = widgetData.getString("widget_message", "주인님, 오늘 뭐 할까?")
            val level = widgetData.getInt("widget_level", 1)
            val streak = widgetData.getInt("widget_streak", 0)

            // UI 업데이트
            views.setTextViewText(R.id.level_text, "Lv.$level")
            views.setTextViewText(R.id.streak_text, "🔥 ${streak}일")
            views.setTextViewText(R.id.message_text, message)

            // 상태에 따른 펫 이미지 변경
            val petDrawable = when (state) {
                "completed" -> R.drawable.pet_default // TODO: pet_happy
                "sulky" -> R.drawable.pet_default // TODO: pet_sulky
                else -> R.drawable.pet_default
            }
            views.setImageViewResource(R.id.pet_image, petDrawable)

            // 뽑기 버튼 클릭 이벤트
            val drawIntent = Intent(context, FetchPetWidgetProvider::class.java).apply {
                action = "DRAW_ACTION"
                data = Uri.parse("fetchpet://draw")
            }
            val drawPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                drawIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.draw_button, drawPendingIntent)

            // 완료 버튼 클릭 이벤트
            val completeIntent = Intent(context, FetchPetWidgetProvider::class.java).apply {
                action = "COMPLETE_ACTION"
                data = Uri.parse("fetchpet://complete")
            }
            val completePendingIntent = PendingIntent.getBroadcast(
                context,
                1,
                completeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.complete_button, completePendingIntent)

            // 버튼 상태 업데이트
            when (state) {
                "waiting" -> {
                    views.setTextViewText(R.id.draw_button, "뽑기")
                    views.setViewVisibility(R.id.complete_button, android.view.View.GONE)
                }
                "result" -> {
                    views.setTextViewText(R.id.draw_button, "다시 뽑기")
                    views.setViewVisibility(R.id.complete_button, android.view.View.VISIBLE)
                }
                "completed" -> {
                    views.setViewVisibility(R.id.draw_button, android.view.View.GONE)
                    views.setViewVisibility(R.id.complete_button, android.view.View.GONE)
                }
                else -> {
                    views.setTextViewText(R.id.draw_button, "뽑기")
                    views.setViewVisibility(R.id.complete_button, android.view.View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            "DRAW_ACTION" -> {
                // 앱으로 딥링크 호출
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    data = Uri.parse("fetchpet://draw")
                }
                context.startActivity(launchIntent)
            }
            "COMPLETE_ACTION" -> {
                // 앱으로 딥링크 호출
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    data = Uri.parse("fetchpet://complete")
                }
                context.startActivity(launchIntent)
            }
        }
    }
}
