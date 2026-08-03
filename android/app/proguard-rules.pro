# Keep Flutter Android embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Ignore warnings for optional Play Core deferred component references in Flutter Engine
-dontwarn com.google.android.play.core.**

# Keep App classes and native AppWidgetProviders (referenced reflectively by class name)
-keep class com.batteryhealth.battery_health_monitor.** { *; }
-keepclassmembers class com.batteryhealth.battery_health_monitor.** { *; }

# Keep HomeWidget plugin and receivers
-keep class es.antonborri.home_widget.** { *; }
-keepclassmembers class es.antonborri.home_widget.** { *; }

# Keep WorkManager background worker and AndroidX WorkManager
-keep class dev.fluttercommunity.workmanager.** { *; }
-keep class androidx.work.** { *; }

# Keep sqflite plugin
-keep class com.tekartik.sqflite.** { *; }

# Keep Flutter Local Notifications plugin and receivers
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# Preserve entry point annotations for background isolates
-keepattributes *Annotation*
