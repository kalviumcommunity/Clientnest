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

---

## Screen Navigation — Flutter Navigator API

This section documents the navigation architecture added in the **Stateful-Widgets** branch.

### Navigation Flow

```
MainScreenWrapper (bottom nav)
    └── HomeScreen  (dashboard tab)
            └── [Navigator API Demo card]
                        └── NavDemoHomeScreen   ← /nav-demo
                                ├── Navigator.push()    → DetailsScreen
                                └── Navigator.pushNamed()  → /details  → DetailsScreen
                                            └── Navigator.pop() → back to NavDemoHomeScreen
```

---

### Named Routes Configuration (GoRouter)

The app uses **GoRouter** for declarative, URL-based navigation. Named paths are registered in `main.dart`:

```dart
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',           builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth-wrapper', builder: (_, __) => const AuthWrapper()),
    GoRoute(path: '/landing',    builder: (_, __) => const LandingPage()),
    GoRoute(path: '/login',      builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',     builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/home',       builder: (_, __) => const MainScreenWrapper()),

    // ── Navigation Demo ───────────────────────────────────────────────────
    GoRoute(path: '/nav-demo',   builder: (_, __) => const NavDemoHomeScreen()),
    GoRoute(
      path: '/details',
      builder: (context, state) => DetailsScreen(
        message: (state.extra as Map<String, dynamic>?)?['message'] as String?,
        method:  (state.extra as Map<String, dynamic>?)?['method']  as String?,
      ),
    ),
  ],
);
```

---

### Navigator.push()

Imperatively pushes a new route onto the Navigator stack with a custom slide transition.

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (_, animation, __) => const DetailsScreen(
      message: 'Navigated via Navigator.push() 🚀',
      method: 'Navigator.push',
    ),
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  ),
);
```

---

### Navigator.pushNamed() (via GoRouter context.push)

Navigates to a named route and passes typed arguments via GoRouter's `extra`:

```dart
// In NavDemoHomeScreen:
context.push('/details', extra: {
  'message': 'Navigated via Navigator.pushNamed() 📌',
  'method': 'Navigator.pushNamed',
});
```

Receiving arguments in DetailsScreen:

```dart
// Via GoRouter extra:
final goExtra = GoRouterState.of(context).extra;
if (goExtra is Map<String, dynamic>) {
  final message = goExtra['message'] as String?;
  final method  = goExtra['method']  as String?;
}

// Via legacy ModalRoute (also supported):
final message = ModalRoute.of(context)!.settings.arguments as String?;
```

---

### Navigator.pop()

Removes the current route from the stack, returning to the previous screen:

```dart
// In DetailsScreen — tapping the back button:
Navigator.pop(context);

// Or via GoRouter:
context.pop();
```

---

### Demo Screenshots

#### Home Screen — Navigator Demo Card
> Run `flutter run`, log in, go to the Home tab, and capture the **"Navigator API Demo"** card.

#### NavDemoHomeScreen
> Tap the card to open `/nav-demo` and screenshot the two method cards.

#### DetailsScreen
> Navigate to DetailsScreen via either method and screenshot the data-received banner.

---

## Reflection — Navigator API

### 1. What is the role of the Navigator in Flutter?

The `Navigator` is Flutter's built-in widget that manages a **stack of routes** (screens). It provides an imperative API (`push`, `pop`, `pushReplacement`, etc.) allowing you to move between screens at runtime. Each `MaterialApp` creates a default `Navigator` at the root — GoRouter builds on top of it to add declarative, URL-aware routing. Screens lower in the stack remain in memory (their widget tree is preserved), so popping back is instant.

### 2. Why are named routes useful in larger applications?

Named routes (`'/details'`, `'/home'`, `'/profile'`) decouple navigation calls from concrete widget imports. Benefits include:

- **Decoupling** — any widget can navigate to `'/details'` without importing the `DetailsScreen` file, reducing coupling between features.
- **Deep linking** — URL-based paths enable direct navigation from notifications or web URLs.
- **Central route registry** — all routes live in one place (`GoRouter` config in `main.dart`), making the navigation graph easy to audit and refactor.
- **Guards & middleware** — GoRouter supports `redirect` callbacks, making it trivial to protect routes behind auth checks without modifying individual screens.

### 3. How does Flutter manage the navigation stack?

Flutter's `Navigator` maintains an ordered list of `Route` objects. Key mechanics:

| Operation | Effect on Stack |
|---|---|
| `Navigator.push(route)` | Adds `route` on top; previous screen stays alive below |
| `Navigator.pop()` | Removes top route; screen below becomes active |
| `Navigator.pushReplacement(route)` | Replaces top route; previous screen is disposed |
| `Navigator.pushAndRemoveUntil(route, pred)` | Pushes route and removes all routes below that don't match `pred` |
| `GoRouter context.push(path)` | Delegate to Navigator.push via GoRouter's internal controller |
| `GoRouter context.go(path)` | Replaces the entire stack with the new path (unlike push) |

When `pop()` is called, Flutter disposes the popped route's widget tree, calls `dispose()` on any `AnimationController`s or streams in that route, and hands focus back to the route below — all in a single frame.

