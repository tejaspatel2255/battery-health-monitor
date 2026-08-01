# Battery Health Monitor 🔋

A production-ready, privacy-focused Android battery health tracking, overheating alert, and power telemetry application built with Flutter & Dart.

## Features ✨

- **Live Battery Dashboard**: Real-time charge %, circular gauge, charging state, temperature (°C), voltage (V), and battery technology.
- **Real-Time Wattage & Charging Speed ⚡**: Live calculation of charging current (**mA**) and charging power (**Watts**) when plugged in.
- **Battery Overheating Warning Alerts ⚠️**: Automatic status bar notification when battery temperature reaches or exceeds **40 °C**.
- **App Battery Drain Profiler 🔋**: Visual breakdown of power consumption across display, active apps, background services, and standby states.
- **Dual Health Precision Paths**:
  - **Measured Health (Root)**: Reads hardware capacity registers (`charge_full` vs `charge_full_design`) from sysfs nodes (`/sys/class/power_supply/battery/`).
  - **Estimated Health (Non-Root)**: Pure Dart delta integration of background charge cycles over time without root requirements.
- **Background Telemetry Logging**: Periodic background telemetry using `WorkManager` into a local SQLite database (`sqflite`).
- **Interactive History Chart**: Visualizes battery level trends over time using `fl_chart`.
- **4 Native Android Home Screen Widgets**:
  - 1x1 Small Widget (Charge %)
  - 2x1 Medium Widget (Charge %, Status, Temperature)
  - 4x2 Large Widget (Charge %, Health Source Badge, Cycle Count, Temperature)
  - Resizable Adaptive Widget (Responsive layout across 3 size breakpoints)
- **Hardened Security & Reliability**:
  - Boot completion recovery (`BOOT_COMPLETED`) for automatic widget restoration.
  - Safe root binary detection (`su` path checks) with graceful fallbacks.
  - 100% unit-tested core calculation engine (9 unit tests).
  - Material 3 Dark theme (zero ads, zero tracking).

## Tech Stack 🛠️

- **Framework**: Flutter (Dart 3.x)
- **Database**: SQLite (`sqflite`)
- **Background Sync**: `workmanager`
- **Notifications**: `flutter_local_notifications`
- **Widgets**: Native Kotlin (`AppWidgetProvider`) + `home_widget`
- **Charting**: `fl_chart`
- **Platform Integration**: Custom Kotlin `MethodChannel` for sticky broadcast telemetry, sysfs node reading, and live wattage calculations.

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

### Running Unit Tests
```bash
flutter test
```

### Building Release APK
1. Create key configuration in `android/key.properties`:
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
