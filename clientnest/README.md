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
│   │   ├── widget_tree_demo.dart  ← Widget Tree & Reactive UI demo
│   │   ├── stateless_stateful_demo.dart ← Stateless vs Stateful demo
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

---

## Widget Tree Explanation

Flutter builds its UI as a **hierarchical tree of widgets**. Every widget is either a *layout widget* (positions children) or a *leaf widget* (renders visible content). The tree for the `WidgetTreeDemoScreen` (`lib/screens/widget_tree_demo.dart`) looks like this:

```
MaterialApp                         ← root of the whole app
└── Scaffold                        ← page skeleton
    ├── AppBar                      ← top navigation bar
    │   ├── Text  ("Widget Tree …") ← title
    │   └── _AccentDot              ← live colour indicator
    └── body
        └── CustomScrollView        ← scrollable viewport
            └── SliverList          ← lazy list of sections
                └── Column
                    ├── _SectionLabel
                    ├── _WidgetTreeCard     ← static tree visualisation
                    │   └── Card
                    │       └── Column
                    │           ├── Row   (header)
                    │           ├── Container  (tree ASCII)
                    │           └── _InfoChip
                    ├── _SectionLabel
                    ├── _CounterCard        ← setState() counter
                    │   └── Card
                    │       └── Column
                    │           ├── Row   (header)
                    │           ├── ScaleTransition  ← animated counter circle
                    │           │   └── Text  (counter value)
                    │           ├── Row   (+ / – buttons)
                    │           │   ├── _CircleButton  (decrement)
                    │           │   └── _CircleButton  (increment)
                    │           └── _CodeAnnotation
                    ├── _SectionLabel
                    ├── _ProfileCard        ← setState() show/hide toggle
                    │   └── Card
                    │       └── Column
                    │           ├── Row     (avatar + name + chevron)
                    │           └── AnimatedSize  ← collapses/expands
                    │               └── Column  (detail rows)
                    ├── _SectionLabel
                    └── _ThemeSwitcherCard  ← setState() colour rotation
                        └── Card
                            └── Column
                                ├── Row   (colour swatches)
                                ├── AnimatedSwitcher  (active label)
                                └── ElevatedButton  ("Next Colour")
```

> **Key insight:**  Flutter re-renders *only* the sub-tree that changed.
> When you tap **+**, Flutter calls `setState()` → `_CounterCard` rebuilds →
> only the counter `Text` and its `ScaleTransition` are repainted.
> Every other card stays exactly as it was.

---

## State Change Demonstration

The `WidgetTreeDemoScreen` has three interactive reactive examples.

### Example 1 — Counter (`_CounterCard`)

| Moment | `_counter` value | What the UI shows |
|---|---|---|
| Initial load | `0` | Circle displays **0**, `–` button dimmed |
| After 3 taps on **+** | `3` | Circle displays **3**, pulse animation plays |
| After tapping **Reset** | `0` | Returns to initial state |

```dart
// State variable (inside _WidgetTreeDemoScreenState):
int _counter = 0;

// Triggered by the + button:
void _increment() {
  setState(() => _counter++);   // ← Flutter rebuilds _CounterCard
  _pulseController.forward(from: 0);
}
```

### Example 2 — Profile Card Toggle (`_ProfileCard`)

| Moment | `_showDetails` | What the UI shows |
|---|---|---|
| Initial load | `false` | Only avatar + name visible |
| After tapping chevron | `true` | Email, Projects, Rating slide in via `AnimatedSize` |
| After tapping again | `false` | Detail rows collapse |

```dart
bool _showDetails = false;

void _toggleDetails() => setState(() => _showDetails = !_showDetails);
```

### Example 3 — Colour Switcher (`_ThemeSwitcherCard`)

| Moment | `_accentIndex` | Colour applied across all cards |
|---|---|---|
| Initial load | `0` | Indigo `#6366F1` |
| 1 tap | `1` | Emerald `#10B981` |
| 2 taps | `2` | Amber `#F59E0B` |
| 3 taps | `3` | Rose `#EF4444` |

```dart
int _accentIndex = 0;

void _nextAccent() =>
    setState(() => _accentIndex = (_accentIndex + 1) % _accents.length);
```

### UI Before Interaction

> **Screenshot placeholder**
> Run `flutter run`, navigate to the Widget Tree Demo screen, and add a screenshot here.

### UI After Interaction

> **Screenshot placeholder**
> Tap the **+** button several times, toggle the profile card, and cycle the colour — then add a screenshot here.

---

## Reflection

### 1. How the Widget Tree Helps Flutter Manage Complex UIs

Flutter builds its entire interface as a **hierarchical widget tree**. This structure gives the framework several advantages:

- **Isolation** — each widget manages its own rendering. A change deep in the tree doesn't force the root or its siblings to repaint.
- **Composability** — complex UIs are built by nesting small, single-responsibility widgets (e.g. `_DetailRow`, `_CircleButton`, `_InfoChip`) rather than one monolithic component.
- **Diffing efficiency** — Flutter's engine walks only the *dirty* sub-tree (widgets marked as needing a rebuild) and skips everything else. In the counter example, tapping **+** rebuilds only `_CounterCard`; the `_ProfileCard` and `_ThemeSwitcherCard` above and below it are never touched.
- **Testability** — because every widget is a pure function of its inputs, individual widgets can be pumped in isolation during widget tests without needing the full app.

### 2. Why Flutter's Reactive Model Is Efficient

Flutter uses a **reactive, declarative UI model** — you describe *what* the UI should look like for a given state, and Flutter figures out *how* to get from the current frame to the next one.

- **`setState()` is surgical.** Calling `setState()` marks only the enclosing `State` object as dirty. Flutter schedules a micro-task to call `build()` on that subtree only on the next frame — not the full widget tree.
- **Element tree reconciliation.** Flutter maintains a persistent *element tree* alongside the widget tree. When a widget rebuilds, Flutter compares the new widget description against the existing element and reuses elements whose `runtimeType` and `key` match. Only genuinely new or changed elements are inflated, keeping frame times low.
- **No manual DOM manipulation.** Unlike imperative frameworks, developers never reach into the widget tree to update a specific node. They update state variables (`_counter`, `_showDetails`, `_accentIndex`) and Flutter propagates the change automatically. This eliminates an entire class of bugs caused by out-of-sync UI state.
- **60 / 120 fps rendering.** Because rebuilds are cheap and targeted, Flutter consistently achieves smooth animations even on mid-range devices — as visible in the pulse animation on the counter circle and the `AnimatedSize` expansion in the profile card.

---

## Stateless vs Stateful Widgets

**Stateless Widgets**
Widgets that display static content and do not change during runtime.

**Stateful Widgets**
Widgets that maintain internal state and update the UI dynamically using `setState()`.

### Code Snippets

**StatelessWidget example**

```dart
class GreetingWidget extends StatelessWidget {
  final String name;

  const GreetingWidget({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

**StatefulWidget example**

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}
```

---

## Demo Screenshots

Here is how the Stateless vs Stateful screen looks and behaves.

### Initial State

> [Insert screenshot]

### Updated State

> [Insert screenshot]

---

## Reflection: Stateless vs Stateful

**When to use StatelessWidget**
Stateless widgets are used for UI elements that do not change after being built.

**When to use StatefulWidget**
Stateful widgets are required when UI needs to change dynamically during runtime.

**How Flutter rebuilds widgets efficiently**
Flutter rebuilds only the widgets affected by state changes instead of redrawing the entire screen.
