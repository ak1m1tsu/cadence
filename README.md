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

## Platform

Android only.

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
make deps    # install dependencies
make run     # run on connected device
make build   # APK + AAB (release)
```

Or directly with Flutter:

```bash
flutter pub get
flutter run
flutter build apk --release
flutter build appbundle --release
```

## Development

```bash
make gen      # re-run Drift code generation after schema changes
make analyze  # static analysis
make test     # run tests
make icons    # regenerate launcher icons from assets/icon.png
make clean    # clean build artifacts
```

## Release

Releases are automated via GitHub Actions. Push a version tag to build and publish APK + AAB to GitHub Releases:

```bash
make release v=1.2.3
```

Android signing is configured via repository secrets (`KEYSTORE_BASE64`, `KEYSTORE_STORE_PASSWORD`, `KEYSTORE_KEY_PASSWORD`, `KEYSTORE_KEY_ALIAS`).

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget, bottom nav
├── core/
│   ├── database/                # Drift schema, DAOs, migrations
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

SQLite via Drift. Tables: `payments`, `categories`, `payment_categories`, `currency_rates_cache`. Default categories (Streaming, Software, Utilities, Gaming, Health, News, Finance, Other) are seeded on first launch.
