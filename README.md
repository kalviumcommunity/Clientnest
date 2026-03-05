# ClientNest – Flutter Project Structure

## Introduction

ClientNest is a Flutter-based mobile application designed to help freelancers manage their **client bookings, earnings, projects, and work schedule** in a single platform.

Flutter automatically generates a structured folder system when a project is created using:

flutter create clientnest

Understanding this structure helps developers organize application code, manage assets, and scale the project efficiently when adding new features like booking management, payment tracking, and notifications.

---

# ClientNest Project Folder Structure

clientnest/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│   ├── models/
│   └── services/
│
├── android/
├── ios/
├── assets/
├── test/
│
├── pubspec.yaml
├── README.md
├── .gitignore
│
├── build/
├── .dart_tool/
└── .idea/

---

# Folder Explanation

## lib/

The **lib folder is the main source code directory** of the ClientNest application.
All Flutter UI, logic, and data models are written in Dart inside this folder.

Example structure used in ClientNest:

lib/
├── main.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── bookings_screen.dart
│   ├── earnings_screen.dart
│   └── profile_screen.dart
│
├── widgets/
│   ├── booking_card.dart
│   ├── earnings_summary.dart
│   └── custom_button.dart
│
├── models/
│   ├── booking_model.dart
│   ├── client_model.dart
│   └── earnings_model.dart
│
└── services/
├── booking_service.dart
├── auth_service.dart
└── payment_service.dart

### main.dart

The **entry point of the ClientNest application**.

It initializes the Flutter app and loads the main UI.

Example:

void main() {
runApp(ClientNestApp());
}

---

# android/

This folder contains all **Android-specific configuration files** required to build the Android version of ClientNest.

It includes:

* Gradle build scripts
* Android manifest
* Native Android configurations

Important file:

android/app/build.gradle

This file defines:

* Application version
* App name
* Android dependencies

---

# ios/

This folder contains **iOS-specific project configuration** used by Xcode to build the iOS version of ClientNest.

Important file:

ios/Runner/Info.plist

It defines:

* App permissions
* Application metadata
* iOS launch settings

---

# assets/

The assets folder stores **static resources used in ClientNest**, such as:

* App icons
* Freelancer illustrations
* Client avatars
* JSON data
* Fonts

Example structure:

assets/
├── images/
│   ├── logo.png
│   ├── freelancer.png
│   └── dashboard_banner.png
│
└── fonts/
└── custom_font.ttf

Assets must be declared in **pubspec.yaml** before they can be used.

Example:

flutter:
assets:
- assets/images/

---

# test/

This folder contains **automated tests for the ClientNest application**.

Flutter supports three types of testing:

1. Unit Tests – test business logic
2. Widget Tests – test UI components
3. Integration Tests – test full app workflow

Default file:

widget_test.dart

This file ensures UI components render correctly.

---

# pubspec.yaml

This is the **main configuration file for the ClientNest project**.

It manages:

* Flutter dependencies
* Asset registration
* App version
* Environment settings

Example dependencies used:

dependencies:
flutter:
sdk: flutter
cupertino_icons: ^1.0.6

Whenever dependencies are added, run:

flutter pub get

---

# Supporting Files

## .gitignore

This file tells Git which files and folders should **not be pushed to the repository**.

Examples:

* build/
* .dart_tool/
* IDE settings

This helps keep the repository clean.

---

## README.md

Contains documentation about the ClientNest project including:

* Project overview
* Setup instructions
* Folder structure explanation
* Developer notes

---

## build/

This folder stores **compiled versions of the application** generated during build.

Important:

Developers should **not manually modify this folder**.

---

## .dart_tool/

Contains internal Flutter and Dart tool configurations used during dependency resolution and builds.

---

## .idea/

Stores IDE configuration files for Android Studio or IntelliJ.

---

# How This Structure Helps ClientNest Scale

A clean folder structure allows the ClientNest application to grow without becoming difficult to manage.

Benefits include:

* Separation of UI, logic, and data models
* Easier feature development
* Better debugging and testing
* Improved collaboration between developers

For example, booking logic can be maintained in services while UI remains inside screens and widgets.

---

# Reflection

Understanding the Flutter project structure is essential for building scalable applications like ClientNest. By organizing code into screens, widgets, models, and services, developers can easily add new features such as payment tracking, client management, and booking notifications without affecting other parts of the application.

This structured approach improves maintainability, readability, and teamwork when working on large Flutter applications.

## Project Structure

ClientNest follows the standard Flutter project architecture.

### Main folders:

- **lib/** – Contains the application logic, UI screens, widgets, models, and services.
- **android/** – Android-specific configuration and build settings.
- **ios/** – iOS-specific configuration files for building the app.
- **assets/** – Stores images, fonts, and other static resources used in the application.
- **test/** – Contains automated tests for the application.
- **pubspec.yaml** – Manages dependencies, assets, and environment configurations.

Detailed documentation about the folder structure can be found in **PROJECT_STRUCTURE.md**.
