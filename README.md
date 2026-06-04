# GlassBudget 📊

> A premium, offline-first Budget Calculator app for Android with **Sri Lankan Rupees (LKR)** support — built with Flutter.

[![License: MIT](https://img.shields.io/badge/License-MIT-teal.svg)](https://github.com/DMStyles/budget_calculator/blob/master/LICENSE)
[![Release](https://img.shields.io/github/v/release/DMStyles/budget_calculator?color=teal)](https://github.com/DMStyles/budget_calculator/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://github.com/DMStyles/budget_calculator/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)

---

## 📥 Download

Get the latest optimized release APK directly for your device:

| APK | Architecture | Size | Best For |
|-----|-------------|------|----------|
| [app-arm64-v8a-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.0.0/app-arm64-v8a-release.apk) | ARM 64-bit | 16.7 MB | ✅ All modern phones (2018+) |
| [app-armeabi-v7a-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.0.0/app-armeabi-v7a-release.apk) | ARM 32-bit | 14.2 MB | Older phones |
| [app-x86_64-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.0.0/app-x86_64-release.apk) | x86_64 | 18.0 MB | Emulators |

> **Not sure which to pick?** Install the `arm64-v8a` APK — it works on virtually all Android phones from the last 6+ years.

---

## ✨ Features

- 💰 **Real-Time Financial Dashboard** — Instantly view your remaining balance, total income, and total expenses in LKR (Rs.)
- 🍩 **Interactive Expense Charts** — Visualizes category-wise spending with interactive pie charts
- 🎯 **Category Budget Goals** — Set custom budget limits per category with live progress bars and overspend alerts
- 📝 **Transaction Manager** — Add, edit, or swipe-to-delete income and expense transactions
- 📴 **Fully Offline** — All data stored securely on-device using SQLite, no internet required
- 🌙 **Premium Dark Mode UI** — Glassmorphism-inspired design with vibrant teal and red accents

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Database | sqflite (SQLite) |
| Charts | fl_chart |
| Date & Formatting | intl |

---

## 🚀 Build From Source

### Prerequisites
- Flutter SDK v3.x or higher
- Android SDK (API 33+ recommended)
- A connected Android device or emulator

### Run in Debug Mode
```bash
git clone https://github.com/DMStyles/budget_calculator.git
cd budget_calculator
flutter pub get
flutter run
```

### Build Optimized Release APKs
```bash
flutter build apk --release --split-per-abi
```

Output files will be located at:
```
build/app/outputs/flutter-apk/
  ├── app-arm64-v8a-release.apk    (16.7 MB)
  ├── app-armeabi-v7a-release.apk  (14.2 MB)
  └── app-x86_64-release.apk       (18.0 MB)
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry, theme, provider setup
├── models/
│   └── transaction.dart             # Transaction data model
├── database/
│   └── database_helper.dart         # SQLite CRUD operations
├── providers/
│   └── budget_provider.dart         # Global state (ChangeNotifier)
├── screens/
│   ├── dashboard_screen.dart        # Main dashboard view
│   └── add_transaction_screen.dart  # Add/Edit transaction form
└── widgets/
    ├── expense_chart.dart            # Pie chart visualization
    └── transaction_list.dart         # Swipeable transaction list
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) © 2026 DMStyles.
