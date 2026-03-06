# ClientNest

A Flutter-based **Freelancer Management App** for tracking clients, projects, payments, and tasks — powered by Firebase (Authentication + Firestore).

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK (bundled with Flutter)
- Firebase project with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) already configured
- VS Code with the Flutter extension **or** any terminal with the Flutter CLI

### Running the App

```bash
# Fetch dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Run tests
flutter test
```

---

## Project Structure

```
clientnest/
├── android/                  → Android platform files
├── ios/                      → iOS platform files
├── assets/
│   ├── images/               → App images & illustrations
│   ├── fonts/                → Custom font files
│   ├── json/                 → Static JSON data / Lottie animations
│   └── logo/                 → App logo assets
├── lib/
│   ├── main.dart             → App entry point, router & providers setup
│   ├── injection_container.dart  → Dependency injection (get_it)
│   │
│   ├── core/                 → App-wide foundations
│   │   ├── constants/        → Shared constants
│   │   ├── error/            → Failure & exception classes
│   │   ├── theme/            → AppTheme (light/dark) & ThemeProvider
│   │   ├── usecases/         → Base UseCase abstraction
│   │   └── utils/            → Utility helpers
│   │
│   ├── features/             → Feature-layered modules (Clean Architecture)
│   │   ├── auth/             → Splash, Landing, Login, Signup screens
│   │   ├── dashboard/        → Dashboard screen
│   │   ├── tasks/            → Task data / domain / presentation layers
│   │   └── payments/         → Payments feature
│   │
│   ├── screens/              → Top-level page screens
│   │   ├── main_screen_wrapper.dart
│   │   ├── home_screen.dart
│   │   ├── responsive_home.dart
│   │   ├── clients_screen.dart
│   │   ├── payments_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── calendar_screen.dart
│   │   ├── projects_screen.dart
│   │   └── projects/         → Project sub-screens (list, detail, create)
│   │
│   ├── widgets/              → Reusable UI components
│   │   ├── freelancer_card.dart
│   │   ├── project_card.dart
│   │   ├── category_chip.dart
│   │   └── google_signin_button.dart
│   │
│   ├── shared/               → Cross-feature shared widgets & components
│   │   └── widgets/          → CustomButtons, TextFields, Dashboard widgets …
│   │
│   ├── services/             → Business-logic & external integrations
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── project_service.dart
│   │   └── pdf_service.dart
│   │
│   ├── models/               → Plain Dart data models
│   │   ├── client_model.dart
│   │   ├── project_model.dart
│   │   ├── task_model.dart
│   │   ├── invoice_model.dart
│   │   └── time_log_model.dart
│   │
│   └── providers/            → ChangeNotifier state providers
│       ├── client_provider.dart
│       ├── project_provider.dart
│       ├── invoice_provider.dart
│       └── time_tracker_provider.dart
│
└── test/
    └── widget_test.dart      → Widget smoke tests
```

---

## Key Technologies

| Area | Package |
|---|---|
| State management | `provider`, `flutter_bloc` |
| Navigation | `go_router` |
| Backend | Firebase Auth, Cloud Firestore |
| Local storage | Hive |
| Dependency injection | `get_it` |
| UI | `google_fonts`, `flutter_animate`, `lottie`, `fl_chart` |
| PDF generation | `pdf`, `printing` |
| Date & time | `table_calendar`, `intl`, `timeago` |

---

## Setup Verification

### Flutter Doctor Output

Run `flutter doctor` and paste output here.

### Running Flutter App

Run `flutter run` and attach a screenshot here.
