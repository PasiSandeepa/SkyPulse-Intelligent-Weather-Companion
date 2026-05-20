<div align="center">

# 🌤️ SkyPulse - AI-Powered Weather Assistant

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen.svg)]()

</div>

---

## 📱 **About SkyPulse**

SkyPulse is an **AI-powered advanced weather application** that provides real-time weather information with beautiful animations, voice assistance, and intelligent insights. Built with Flutter and integrated with OpenWeatherMap API and Google's Gemini AI.

### ✨ **Key Features**

| Feature | Description |
|---------|-------------|
| 🌍 **Live Location** | Automatic GPS-based weather tracking |
| 🔍 **City Search** | Search weather for any city worldwide |
| 🤖 **AI Insights** | Gemini AI-powered weather recommendations |
| 🎙️ **Voice Assistant** | Ask about weather using voice commands |
| 🌈 **Dynamic Animations** | Weather-based Lottie animations |
| 📊 **5-Day Forecast** | Interactive temperature charts |
| 🌓 **Dark/Light Theme** | Automatic theme switching |
| 🔔 **Notifications** | Weather alerts and daily updates |
| ❤️ **Favorites** | Save your favorite cities |
| 👤 **User Profile** | Personalized user experience |

---

## 🎨 **Screenshots**

<div align="center">

### Splash & Home Screen
| Splash | Home (Light) | Home (Dark) |
|:------:|:------------:|:-----------:|
| <img src="assets/screenshots/Screenshot 2026-05-20 105421.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105440.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105526.png" width="200"> |

### Weather Details & AI Insights
| Weather Details (Light) | Weather Details (Dark) | AI Forecast |
|:-----------------------:|:----------------------:|:-----------:|
| <img src="assets/screenshots/Screenshot 2026-05-20 105538.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105549.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105617.png" width="200"> |

### Voice Assistant & Profile
| Voice (Light) | Voice (Dark) | Profile (Dark) | Profile (Light) |
|:-------------:|:------------:|:---------------:|:--------------:|
| <img src="assets/screenshots/Screenshot 2026-05-20 105629.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105640.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105652.png" width="200"> | <img src="assets/screenshots/Screenshot 2026-05-20 105708.png" width="200"> |

</div>

---

## 🛠️ **Tech Stack**

<div align="center">

| Category | Technologies |
|----------|--------------|
| **Frontend** | Flutter, Dart |
| **State Management** | flutter_bloc, equatable |
| **API Integration** | Dio, HTTP |
| **AI/ML** | Google Gemini AI |
| **Voice** | speech_to_text, flutter_tts |
| **Location** | geolocator, geocoding |
| **Storage** | shared_preferences, hive |
| **Animations** | Lottie |
| **Charts** | fl_chart |
| **Notifications** | flutter_local_notifications |

</div>

---

## 🚀 **Getting Started**

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/PasiSandeepa/SkyPulse-Intelligent-Weather-Companion.git

# Navigate to project
cd skypulse_app

# Get dependencies
flutter pub get

# Create .env file with your API keys
echo "OPENWEATHER_API_KEY=your_key_here" > .env
echo "GEMINI_API_KEY=your_key_here" >> .env

# Run the app
flutter run
```

---

## 📁 **Project Structure**
lib/
├── core/
│   ├── api/              # API services
│   ├── services/         # Location, Notification services
│   └── utils/            # Validators, constants
├── data/
│   ├── datasources/      # Local data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository pattern
├── domain/
│   ├── entities/         # Business entities
│   └── usecases/         # Use cases
└── presentation/
├── bloc/             # State management
├── pages/            # UI Screens
└── widgets/          # Reusable components

---

## 📄 **License**

This project is licensed under the MIT License.

---

<div align="center">
Made with ❤️ by Pasindu Sandeepa
</div>
bashgit add README.md
git commit -m "Fix README structure and duplicate sections"
git push
