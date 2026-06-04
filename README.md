# GlassBudget 📊

GlassBudget is a visually stunning, premium, and native-feeling Budget Calculator mobile application built for Android using Flutter. It is customized for **Sri Lankan Rupees (LKR)** and runs entirely offline to keep your financial data private.

## ✨ Features

- 💰 **Real-Time Financial Dashboard:** Instantly view your remaining balance, total income, and total expenses.
- 🎨 **Premium Modern Design:** Symmetrical layout featuring a near-black dark mode, glassmorphism card highlights, and micro-animations.
- 🍩 **Interactive Expense breakdown:** Visualizes your category-wise spending using interactive pie charts (utilizing `fl_chart`).
- 🎯 **Category Budget Goals:** Set custom budget limits for different expense categories (Food, Housing, Utilities, etc.) with real-time progress bars and alerts when limits are exceeded.
- 📝 **Transaction Manager:** Easily add, edit, or delete transactions. Supports swipe-to-delete with confirmation modal.
- 📂 **Offline SQLite Database:** Fully local data persistence using `sqflite` so your transactions are stored securely on your phone.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
- **Data Visualizations:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Date/Currency Helper:** [intl](https://pub.dev/packages/intl)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.x or higher)
- Android SDK (v33+ recommended)
- A connected Android Device or Emulator

### Installation & Run

1. Clone this repository:
   ```bash
   git clone https://github.com/DMStyles/budget_calculator.git
   cd budget_calculator
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application in debug mode:
   ```bash
   flutter run
   ```

---

## 📦 Production Builds & Optimizations

This app includes R8 ProGuard rules, resource shrinking, and code minification enabled inside `android/app/build.gradle.kts` to keep the install footprint extremely low.

To build the highly optimized release APKs split by device CPU architecture (reducing download size from 48MB to 16MB):

```bash
flutter build apk --release --split-per-abi
```

The output APKs will be located at:
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
