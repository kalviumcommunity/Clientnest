## Flutter & Dart Fundamentals: ClientNest

### Widget Analysis
- **StatelessWidget:** Used for `ClientProfileHeader`. It remains static after the data is fetched.
- **StatefulWidget:** Used for `TaskTracker`. It handles user interactions like marking tasks as 'Complete' using `setState()`.

### Reactive Rendering Performance
ClientNest maintains high performance by:
1. **Minimizing Rebuilds:** We use localized state management so only modified elements re-render.
2. **Dart Async Model:** Using `FutureBuilder` and `StreamBuilder` for Firebase ensures the UI thread is never blocked during data fetching.
