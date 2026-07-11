# 🚁 Drone Delivery System Simulation

A modern, animated **Drone Delivery System Simulation** built with **Flutter**. This is a complete offline simulation that demonstrates how a commercial drone logistics dashboard would look and feel.

> ⚠️ This is a **simulation**, not a real drone control system. Everything runs locally.

---

## ✨ Highlights

- 🎨 **Premium dashboard UI** with dark mode, blue accents, glassmorphism, gradients, and smooth animations.
- 🗺️ **Custom hand-drawn city map** (no Google Maps / OpenStreetMap dependency).
- 🚁 **Animated drone** with rotating propellers, smooth interpolation, takeoff/land/fly cycles.
- 📦 **Package selection** (Food, Medicine, Parcel, Documents).
- 📊 **Statistics dashboard** with `fl_chart` and animated counters.
- 🔔 **Notification system** that slides in from the top-right.
- 💾 **Fully offline** — data is stored locally with `SharedPreferences` (JSON-encoded).
- 🧠 **Clean architecture** with feature-based folders and Riverpod state management.

---

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

That's it. No backend, no Firebase, no API keys.

---

## 🧱 Tech Stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (Material 3) |
| Language | Dart |
| State | Riverpod |
| Storage | SharedPreferences (JSON) |
| Charts | fl_chart |
| Animations | AnimationController, Tween, AnimatedContainer, Hero, CustomPainter |

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── constants/      # Strings, dimensions, enums
│   ├── theme/          # Colors, theme data, gradients
│   └── utils/          # Helpers, formatters
├── data/
│   ├── models/         # Domain models
│   ├── providers/      # Riverpod providers
│   └── services/       # Storage & business services
├── features/
│   ├── home/           # Landing screen
│   ├── map/            # Custom city map
│   ├── package/        # Package selection
│   ├── drone/          # Drone info panel
│   ├── statistics/     # Stats dashboard
│   ├── controls/       # Simulation controls
│   ├── notifications/  # Toast notifications
│   └── summary/        # Delivery summary dialog
├── simulation/         # Mission simulator, city data, calculator
├── widgets/            # Reusable widgets
└── main.dart
```

---

## 🎮 Features

1. **Home Screen** with animated logo, drone illustration, and CTA buttons.
2. **Interactive City Map** with 10 hand-placed delivery locations.
3. **Package Selection** (Food 🍔, Medicine 💊, Parcel 📦, Documents 📄).
4. **Drone Info Panel** — battery, speed, mission status, animated circular indicator.
5. **Drone Simulation** — takeoff, fly, land, deliver, return — with interpolated motion.
6. **Camera Modes** — Default, Follow Drone, Top View.
7. **Route Visualization** — animated route drawing as the drone moves.
8. **Battery System** — depletes based on distance and weight; color shifts green → yellow → red.
9. **Delivery Progress** — animated stage tracker.
10. **Delivery Summary** dialog with detailed cost & time breakdown.
11. **Random Order Generator** after each delivery (accept / skip / regenerate).
12. **Statistics Dashboard** with `fl_chart` and animated counters.
13. **Notification System** sliding from the top-right.
14. **Simulation Controls** — Start / Pause / Resume / Reset / New Order.

---

## 💰 Cost Formula

```
total = baseCost + (distanceKm * costPerKm) + (weightKg * costPerKg)
```

## 🔋 Battery Formula

```
drain = (distanceKm * 0.8) + (weightKg * 2.0) + (missionOverhead)
```

---

## 🧪 Tested On

- Flutter 3.19+
- Dart 3.3+
- Android, Windows, Web (desktop & mobile layouts supported)

---

## 📄 License

MIT — free to use, modify, and learn from.