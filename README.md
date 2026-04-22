# Flutter Weather App

A **self-contained Flutter weather app** demonstrating clean UI, robust async handling, and thoughtful UX. Written exclusively by me as a code sample for evaluation.

## Features

* Search weather by city name
* Handles asynchronous API calls safely with race-condition prevention
* Displays loading indicators and error messages
* Dynamic UI: weather emoji and background color change based on conditions
* Clean and maintainable UI code structure

## Getting Started

1. **Clone the repository:**

```bash
git clone https://github.com/YOUR_USERNAME/flutter-weather-app.git
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Run the app:**

```bash
flutter run
```

## Code Highlights

* `WeatherPage` uses `setState` with `_requestId` to avoid stale data from async calls
* Error handling and UX enhancements (keyboard dismissal, button disabling)
* Helper methods `_buildLoading`, `_buildError`, `_buildSuccess` keep UI clean
* Fully null-safe and follows Flutter best practices

## Notes

* All code is written exclusively by me
* Can be run independently without additional setup
* Designed to showcase Flutter skills and coding best practices

---

Created by **Katherine Kathy**
