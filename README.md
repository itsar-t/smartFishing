# SmartFishing

A cross-platform mobile application built with Flutter that helps recreational anglers track catches, explore fishing spots, check conditions, and learn techniques — all in one place.

---

## Features

| Module | Description |
|---|---|
| **Social Feed** | Share catches with photos, view posts from other anglers |
| **Interactive Map** | GPS-based map with WMS marine overlays, fish markers, and suggested fishing spots |
| **Fishing License** | Swedish fishing licence info per county |
| **Weather Forecast** | 5-day forecast tailored to fishing conditions |
| **Learn Fishing** | Guides covering conditions, tides, gear, lures, and fish species |
| **Authentication** | Email/password accounts with guest (anonymous) mode via Firebase Auth |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend & Auth:** Firebase — Authentication, Cloud Firestore, Storage
- **Maps:** flutter_map with WMS (Web Map Service) tile layers and custom GPS integration
- **Weather:** Google Weather API via a custom service wrapper
- **Media:** image_picker, photo_manager, cached_network_image
- **Other:** geolocator, flutter_svg, shimmer, url_launcher

---

## Screenshots

> *Coming soon*

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.9.2`
- A Firebase project with Android & iOS apps configured
- A `.env` file in the project root with your API keys (see below)

### Environment variables

Create a `.env` file at the project root:

```
GOOGLE_WEATHER_API_KEY=your_key_here
```

### Install & run

```bash
flutter pub get
flutter run
```

### Firebase setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Anonymous)
3. Enable **Cloud Firestore** and **Storage**
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the respective platform directories
5. Update `lib/firebase_options.dart` with your project config

---

## Project Structure

```
lib/
├── main.dart               # App entry point, theme, routing
├── firebase_options.dart
├── models/                 # Data models (Post, …)
├── pages/                  # Full-screen pages
│   ├── home_page.dart      # Shell with bottom navigation
│   ├── feed_page.dart      # Social catch feed
│   ├── marine_map_page.dart
│   ├── learn_fishing_page.dart
│   ├── licence_page.dart
│   └── …
├── widgets/                # Reusable UI components
└── utils/                  # Services & helpers (weather, WMS, auth)
```

---

## Roadmap

- [ ] User profile page
- [ ] In-app catch logging with species & weight
- [ ] Push notifications for weather alerts
- [ ] Expanded fish species database

---

## License

This project is for educational and portfolio purposes. All rights reserved.
