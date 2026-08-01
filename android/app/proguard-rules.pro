# Keep Flutter Android embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep native HomeWidget providers
-keep class es.antonborri.home_widget.** { *; }
-keep class com.batteryhealth.battery_health_monitor.** { *; }

# Keep WorkManager background worker
-keep class dev.fluttercommunity.workmanager.** { *; }
