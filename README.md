# WikiPlaces

A native iOS app that fetches a [curated list](https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json) of locations and opens each one directly in the [Modified Wikipedia iOS app](https://github.com/tejas786u/wikipedia-ios/tree/LatLong_DeepLinkSupport) using a deep link (`wikipedia://places`).

---

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/tejas786u/WikiPlacesApp.git
   cd WikiPlacesApp
   ```

2. **Open in Xcode**
   ```bash
   open WikiPlacesApp.xcodeproj
   ```

3. **Run the app**
   Select an iOS 17+ simulator and press `⌘R`.

4. **Open a location in Wikipedia**
   The app requires the [modified Wikipedia iOS app](https://github.com/tejas786u/wikipedia-ios/tree/LatLong_DeepLinkSupport) to be installed on the same device or simulator. Without it, the app shows a "Wikipedia App Not Found" alert instead of crashing.

---

## Features

- **Location List** - Fetches locations from a remote JSON feed and displays them as interactive cards
- **Staggered Animations** - Location cards slide in from the right, one by one (100 ms stagger for the first 7 cards, immediate for scrolled cards), driven by `onAppear` inside each `LocationCard`; skeleton cards display a shimmer only with no slide; Reduce Motion skips the offset and fades cards in instead
- **Tap Depth Animation** - Tapping a location card scales it down to 93 % with a compressed shadow, then springs back with a subtle bounce before opening Wikipedia - gives a physical "press" feel; skipped entirely when Reduce Motion is on
- **Skeleton Loading** - Animated shimmer placeholder cards while the network request is in flight
- **Error & Empty States** - Distinct views with accessible retry/refresh actions
- **Custom Location** - Enter any latitude/longitude (with an optional name) to open an coordinate in Modified Wikipedia app
- **Local Data Mode** - Flip a single `useLocalData` flag in `DependencyInjector` to load locations from a bundled JSON file instead of the network (useful for offline development and testing)
- **Deep Link Integration** - Opens locations in Modified Wikipedia app via the `wikipedia://places?lat=…&lon=…` URL scheme
- **"App Not Installed" Alert** - Graceful fallback alert when the Wikipedia app is not present on the device
- **Full Accessibility** - VoiceOver labels/hints on all interactive elements, decorative elements hidden from assistive technologies, Reduce Motion respected throughout all animations

---

## Demo

▶️ [Watch App Demo](https://drive.google.com/file/d/13G_RpqTY4HHZ-QMeYY-0ANMytc1_JNUt/view?usp=sharing)

---

## Screenshots

| Skeleton | Location List | Custom Location | Open in Wikipedia | Not Installed Alert |
|:---:|:---:|:---:|:---:| :---: |
| ![Skeleton](Screenshots/skeleton.png) | ![Location List](Screenshots/locationslist.png) | ![Custom Location](Screenshots/customlocation.png) | ![Open in wikipedia](Screenshots/redirectwikipedia.png) | ![Alert](Screenshots/nowikiapp.png) |

---

## Architecture

The app follows **MVVM** with a protocol-oriented dependency injection layer. All ViewModels are `@MainActor`-isolated, ensuring `@Published` mutations always occur on the main thread without manual `DispatchQueue.main` calls.

```
┌─────────────────────────────────────────┐
│              SwiftUI Views              │
│ ContentView → LocationsListView         │
│             → CustomLocationView (sheet)│
└──────────────────┬──────────────────────┘
                   │  @StateObject / @ObservedObject
┌──────────────────▼──────────────────────┐
│               ViewModels                │
│  LocationsListViewModel  (@MainActor)   │
│  CustomLocationViewModel (@MainActor)   │
└──────┬─────────────────────┬────────────┘
       │                     │
┌──────▼────────┐   ┌────────▼───────────────┐
│  Networking   │   │  DeepLink Service      │
│ NetworkService│   │  WikipediaOpener       │
│LocationService│   │  WikipediaDeepLink     │
└───────────────┘   └────────────────────────┘
   ▲                                    ▲
   └──────── DependencyInjector ────────┘
```

## Project Structure

```
WikiPlacesApp/
├── WikiPlacesApp/
│   ├── WikiPlacesAppApp.swift              # App entry point (@MainActor)
│   ├── DI/
│   │   └── DependencyInjector.swift        # Factory — all dependencies wired here; toggle useLocalData to switch data source
│   ├── Models/
│   │   └── Location.swift                  # Identifiable, Equatable, Decodable
│   ├── Networking/
│   │   ├── NetworkService.swift            # Generic URLSession wrapper
│   │   └── LocationServiceImp.swift        # LocationServiceImp (remote) + LocalLocationService (bundled JSON)
│   ├── Services/
│   │   └── DeepLink/
│   │       ├── DLConfiguration.swift       # WikipediaConfig constants
│   │       ├── DLBuilder.swift             # WikipediaDeepLink — URL builder
│   │       └── DLOpener.swift              # WikipediaOpener — UIApplication bridge
│   ├── ViewModels/
│   │   ├── LocationsListViewModel.swift    # List state machine + open action
│   │   └── CustomLocationViewModel.swift   # Field validation for custom coordinates
│   └── Views/
│       ├── ContentView.swift               # Root view — nav stack, sheet, alert
│       ├── LocationList/
│       │   ├── LocationsListView.swift     # Scroll container + .task loader
│       │   ├── ListContentView.swift       # State-driven switch (loading/loaded/error/empty)
│       │   ├── LocationCard.swift          # LocationCard (right→left slide-in, stagger, tap depth animation) + LocationCardSkeleton (shimmer)
│       │   └── StatusView.swift            # Reusable error/empty state view
│       ├── CustomLocation/
│       │   └── CustomLocationView.swift    # Form sheet for custom lat/lon entry
│       └── SupportingView/
│           ├── BackgroundGradient.swift
│           ├── PressableButtonStyle.swift  # Scale + opacity press feedback
│           └── ShakeEffect.swift           # GeometryEffect for validation shake
│   └── SupportingFiles/
│       └── LocalTestJSON/
│           └── locations.json              # Bundled fallback data used by LocalLocationService
├── WikiPlacesAppTests/                     # Unit test target
│   ├── DI/
│   │   └── DependencyInjectorTests.swift
│   ├── Models/
│   │   └── LocationTests.swift
│   ├── Networking/
│   │   ├── NetworkServiceTests.swift
│   │   └── LocationServiceImpTests.swift
│   ├── Services/
│   │   └── DLBuilderTests.swift
│   ├── ViewModels/
│   │   ├── LocationsListViewModelTests.swift
│   │   └── CustomLocationViewModelTests.swift
│   └── Mocks.swift
└── WikiPlacesAppUITests/                   # UI test target
    └── Views/
        ├── LocationsListViewUITests.swift
        └── CustomLocationViewUITests.swift
```

---

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |

## Testing

### Unit Tests — `WikiPlacesAppTests`

Run with `⌘U` (or select the `WikiPlacesAppTests` scheme).

| Folder | File | What is covered |
|---|---|---|
| Models | `LocationTests.swift` | `displayName` fallback, `coordinateString` format, Decodable (`lat`/`long` keys), Equatable |
| Networking | `NetworkServiceTests.swift` | Successful decode, HTTP error → `invalidResponse`, malformed JSON → `decodingError`, cache policy, `URLError` passthrough |
| Networking | `LocationServiceImpTests.swift` | Fetch success, service-level error, call counts, default and custom endpoint URL |
| Services | `DLBuilderTests.swift` | Correct scheme/host, `lat`/`lon` query items, optional `name` inclusion and omission, query item ordering |
| ViewModels | `LocationsListViewModelTests.swift` | All `LocationsListState` transitions (`idle → loading → loaded/error`), retry, refresh, open success/failure, `isShowingNotInstalledAlert` |
| ViewModels | `CustomLocationViewModelTests.swift` | Boundary coordinate values, validation error messages, name whitespace trimming, re-validation after first failure |
| DI | `DependencyInjectorTests.swift` | Factory returns correct concrete types, ViewModel starts in `.idle` state |

### UI Tests — `WikiPlacesAppUITests`

Run with `⌘U` against the `WikiPlacesAppUITests` scheme.

| File | What is covered |
|---|---|
| `LocationsListViewUITests.swift` | Navigation title present, add-location button exists and is enabled, content list visible after load, error state retry button tappable, empty state refresh button tappable |
| `CustomLocationViewUITests.swift` | Sheet opens on button tap, all form fields present, cancel dismisses the sheet, submitting empty fields shows validation errors, full flow with Wikipedia-not-installed alert |

### Test Mocks — `Mocks.swift`

| Mock | Purpose |
|---|---|
| `MockLocationsService` | Stubs `fetchLocations()` with a configurable success or failure |
| `MockWikiOpener` | Stubs `openDeepLink()`, records call count and last location passed |
| `MockNetworkService` | Generic `fetch<T>()` stub using `Any` result casting |
| `MockURLProtocol` | Intercepts `URLSession` requests for `NetworkService` integration tests |

---

## Accessibility

| Feature | Implementation |
|---|---|
| VoiceOver labels | All interactive elements have explicit `accessibilityLabel` and `accessibilityHint` |
| Decorative elements | Background gradient and icon images are marked `.accessibilityHidden(true)` |
| Button independence | Error/empty state action buttons are **not** merged with surrounding text - they remain independently activatable by VoiceOver |
| Reduce Motion | Card slide-in stagger (offset skipped, fade only), tap depth animation (scale + shadow skip), skeleton shimmer, button press scale, validation shake, and status view pop-in all skip their animations when `accessibilityReduceMotion` is enabled |

---

## Deep Link Format

```
wikipedia://places?lat={latitude}&lon={longitude}[&name={name}]
```

**Example:**
```
wikipedia://places?lat=52.3676&lon=4.9041&name=Amsterdam
```

The `wikipedia` URL scheme is registered in `Info.plist` under `LSApplicationQueriesSchemes` so `UIApplication.canOpenURL(_:)` works correctly before attempting to launch the app.

---

## Data Source

Locations are fetched from:
```
https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json
```

---

## License

This project was created as part of an iOS take-home assignment.
