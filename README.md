# Battery Health Monitor 🔋

A production-ready, privacy-focused Android battery health tracking, overheating alert, and power telemetry application built with Flutter & Dart.

## Features ✨

- **Live Battery Dashboard**: Real-time charge %, circular gauge, charging state, temperature (°C), voltage (V), and battery technology.
- **Real-Time Wattage & Charging Speed ⚡**: Live calculation of charging current (**mA**) and charging power (**Watts**) when plugged in.
- **Battery Overheating Warning Alerts ⚠️**: Automatic status bar notification when battery temperature reaches or exceeds **40 °C**.
- **Isolate-Safe Background Alerts 🛡️**: Notification permissions are persisted across background Dart isolates so 15-minute WorkManager tasks never trigger headless permission prompts or fail telemetry logging.
- **Decoupled Telemetry Performance ⚡**:
  - **Fast 5s Loop**: Live battery level, temperature, voltage, and wattage polling via fast platform channels.
  - **Slow 60s Loop**: Full wear & cycle calculation from SQLite logs with `idx_battery_logs_timestamp` indexing (reducing database disk reads by 91.7%).
- **App Battery Drain Profiler 🔋**: Visual breakdown of power consumption across display, active apps, background services, and standby states.
- **Dual Health Precision Paths**:
  - **Measured Health (Root)**: Reads hardware capacity registers (`charge_full` vs `charge_full_design`) from sysfs nodes (`/sys/class/power_supply/battery/`).
  - **Estimated Health (Non-Root)**: Pure Dart delta integration of background charge cycles over time without root requirements.
- **Safe Background Root Execution 🛡️**: Caches superuser grant status in the foreground to prevent headless background isolates from triggering interactive SU permission dialogs.
- **Background Telemetry Logging**: Idempotent periodic background telemetry using `WorkManager` into a local SQLite database (`sqflite`).
- **4 Native Android Home Screen Widgets**:
  - 1x1 Small Widget (Charge %, Temperature)
  - 2x1 Medium Widget (Charge %, Status, Temperature)
  - 4x2 Large Widget (Charge %, Health Source Badge, Cycle Count, Temperature)
  - Resizable Adaptive Widget (Responsive layout across 3 size breakpoints)
- **Platform Guarding**: Android-only platform guards with a dedicated `UnsupportedPlatformScreen` for non-Android targets.
- **Custom App Branding**: Premium 3D glowing battery app icon across all Android mipmap densities (`mdpi` to `xxxhdpi`).
- **Hardened Security & Production Build**:
  - R8 Code Minification & Resource Shrinking enabled with custom ProGuard keep rules.
  - Boot completion recovery (`BOOT_COMPLETED`) for automatic widget restoration.
  - Safe root binary detection (`su` path checks) with label-based sysfs parsing and graceful fallbacks.
  - 100% test coverage backed by SQLite FFI and mock platform channels.
  - Material 3 Dark theme (zero ads, zero tracking, zero telemetry data sent externally).

## Tech Stack 🛠️

- **Framework**: Flutter (Dart 3.x)
- **Database**: SQLite (`sqflite` with `sqflite_common_ffi` test bindings and timestamp index)
- **Background Sync**: `workmanager`
- **Notifications**: `flutter_local_notifications`
- **Widgets**: Native Kotlin (`AppWidgetProvider`) + `home_widget`
- **Charting**: `fl_chart`
- **Platform Integration**: Custom Kotlin `MethodChannel` for sticky broadcast telemetry, sysfs node reading, and live wattage calculations.

## Security & Privacy 🔐

This app is 100% local and privacy-first:
- **No Analytics or Remote Tracking**: Zero network requests or telemetry endpoints.
- **Protected Signing Keys & Credentials**: All signing keystores (`*.jks`, `*.keystore`), `key.properties`, environment configs (`.env*`), and private certificate files are strictly ignored via `.gitignore` and excluded from version control history.

## Getting Started 🚀

### Prerequisites
- Flutter SDK (3.x or newer)
- Android SDK (API level 26+ / Android 8.0+)
- JDK 17

### Installation
```bash
git clone https://github.com/tejaspatel2255/battery-health-monitor.git
cd battery-health-monitor
flutter pub get
```

### Running the App
```bash
flutter run
```

### Running Unit & Widget Tests
```bash
flutter test
```

### Static Analysis
```bash
flutter analyze
```

### Building Release APK
1. Create key configuration in `android/key.properties` (never commit this file):
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEYSTORE_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
2. Build the release APK:
   ```bash
   flutter build apk --release
   ```

## License 📄

This project is open source and available under the [MIT License](LICENSE).
