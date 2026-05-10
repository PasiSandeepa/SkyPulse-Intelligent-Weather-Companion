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

<!-- <div align="center">

### Home Screen & Weather Display

| Weather Details | 5-Day Forecast |
|:---------------:|:--------------:|
| <img src="assets/screenshots/home_screen.png" width="250"> | <img src="assets/screenshots/forecast.png" width="250"> |

### AI Voice Assistant & City Search

| Voice Assistant | Search Feature |
|:---------------:|:--------------:|
| <img src="assets/screenshots/voice_assistant.png" width="250"> | <img src="assets/screenshots/search.png" width="250"> |

### Profile & Settings

| Profile Page | Weather Metrics |
|:------------:|:---------------:|
| <img src="assets/screenshots/profile.png" width="250"> | <img src="assets/screenshots/weather_details.png" width="250"> |

### Air Quality & Insights

| AQI Display | AI Insights |
|:-----------:|:-----------:|
| <img src="assets/screenshots/aqi.png" width="250"> | <img src="assets/screenshots/ai_insight.png" width="250"> |

</div> -->

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

```bash
Flutter SDK (>=3.0.0)
Dart SDK (>=3.0.0)
Android Studio / VS Code

# Clone the repository
git clone https://github.com/yourusername/skypulse.git

# Navigate to project
cd skypulse

# Get dependencies
flutter pub get

# Create .env file with your API keys
echo "OPENWEATHER_API_KEY=your_key_here" > .env
echo "GEMINI_API_KEY=your_key_here" >> .env

# Run the app
flutter run

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
