# Cadence

A Flutter app for tracking recurring payments and subscriptions. Know what renews, when, and how much — before it hits your account.

## Features

- **Payment tracking** — add any recurring payment with name, price, currency, billing cycle, and start date
- **Flexible billing cycles** — daily, weekly, monthly, yearly, or custom intervals (e.g. every 3 months)
- **Dashboard** — spending breakdown by category with charts; switch between monthly and yearly views
- **Reminders** — per-payment push notifications with configurable lead time and time of day
- **Categories** — multi-category tagging with custom colors and icons
- **Multi-currency** — per-payment currency with live exchange rate conversion
- **Icon picker** — emoji or letter avatar with custom color per payment
- **Themes** — light, dark, and system

## Platforms

| Platform | Status |
|----------|--------|
| Android  | ✓      |
| macOS    | ✓      |
| Windows  | ✓ (notifications not supported) |

## Tech Stack

| Layer | Library |
|-------|---------|
| UI | Flutter + Material 3 |
| State | Riverpod 2 |
| Database | Drift (SQLite) |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Settings | shared_preferences |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Build for production
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build macos
flutter build windows
```

## Code Generation

Drift requires generated code. Run after any schema change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget, bottom nav
├── core/
│   ├── database/                # Drift schema (v5), DAOs, migrations
│   ├── models/                  # AppSettings, BillingCycle
│   ├── services/                # Notifications, currency rates, renewal calculator
│   └── theme/                   # Light/dark themes
└── features/
    ├── payments/                 # List, detail, add/edit form
    ├── dashboard/                # Spending summary and charts
    ├── categories/               # Category management
    └── settings/                 # Theme, currency, notifications
```

## Database

SQLite via Drift, schema version 5. Tables: `payments`, `categories`, `payment_categories`, `currency_rates_cache`. Default categories (Streaming, Software, Utilities, Gaming, Health, News, Finance, Other) are seeded on first launch.

## App Icon

Source image: `assets/icon.png`. Regenerate platform icons after replacing it:

```bash
dart run flutter_launcher_icons
```
