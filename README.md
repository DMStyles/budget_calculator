# Glass Budget 📊

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
| [Glass_Budget-v1.1.0-arm64-v8a-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.1.0/Glass_Budget-v1.1.0-arm64-v8a-release.apk) | ARM 64-bit | 18.0 MB | ✅ All modern phones (2018+) |
| [Glass_Budget-v1.1.0-armeabi-v7a-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.1.0/Glass_Budget-v1.1.0-armeabi-v7a-release.apk) | ARM 32-bit | 15.6 MB | Older phones |
| [Glass_Budget-v1.1.0-x86_64-release.apk](https://github.com/DMStyles/budget_calculator/releases/download/v1.1.0/Glass_Budget-v1.1.0-x86_64-release.apk) | x86_64 | 19.4 MB | Emulators |

> **Not sure which to pick?** Install the `arm64-v8a` APK — it works on virtually all Android phones from the last 6+ years.

---

## ✨ Features

- 💰 **Real-Time Financial Dashboard** — Instantly view your remaining balance, total income, and total expenses in LKR (Rs.)
- 📊 **Monthly Reports & Insights** — Beautiful monthly analytics sheets showing total income/spending breakdowns, daily spending averages, top spending categories, net savings, and savings rate.
- ⚙️ **Settings & Preferences** — Toggle between Light Mode, Slate Charcoal Dark Mode, or Follow System.
- 🔄 **GitHub Update Checker** — Check for updates directly inside the app with release note view and in-app update launch prompts.
- 🍩 **Interactive Expense Charts** — Visualizes category-wise spending with interactive pie charts, now featuring a dedicated **Saving** category.
- 🎯 **Category Budget Goals** — Set custom budget limits per category (now including savings allocations) with live progress bars and overspend alerts.
- 📝 **Transaction Manager** — Add, edit, or swipe-to-delete income and expense transactions.
- 📴 **Fully Offline & Secure** — All data stored locally using SQLite, respecting user privacy.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Database | sqflite (SQLite) |
| Preferences | shared_preferences |
| Network & Updates | http & package_info_plus |
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

Rename and locate the output files:
```
Glass_Budget-v1.1.0-arm64-v8a-release.apk    (18.0 MB)
Glass_Budget-v1.1.0-armeabi-v7a-release.apk  (15.6 MB)
Glass_Budget-v1.1.0-x86_64-release.apk       (19.4 MB)
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry, Material 3 navigation hub, theme config
├── models/
│   └── transaction.dart             # Transaction data model
├── database/
│   └── database_helper.dart         # SQLite CRUD operations
├── providers/
│   └── budget_provider.dart         # Global state & settings preferences provider
├── screens/
│   ├── dashboard_screen.dart        # Main dashboard view
│   ├── reports_screen.dart          # Monthly report sheets & insights
│   ├── settings_screen.dart         # App settings, theme selectors, update checker
│   └── add_transaction_screen.dart  # Add/Edit transaction form
└── widgets/
    ├── expense_chart.dart            # Pie chart breakdown
    └── transaction_list.dart         # Swipeable transaction list
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) © 2026 DMStyles.
