# 🛰️ PulsePoint: Advanced Syndromic Surveillance

**PulsePoint** is a state-of-the-art health intelligence platform designed for real-time syndromic surveillance and environmental risk assessment. By merging localized health "pulses" with climate intelligence, it empowers health authorities to detect and mitigate outbreaks before they escalate.

---

## ✨ Key Features

- **🏥 Health Monitor**: A high-fidelity dashboard for tracking regional health anomalies and "pulse" velocity.
- **🌩️ Environmental Risk Intelligence**: Real-time integration with OpenWeather to calculate climate-driven health risks (respiratory, vector-borne, and thermal stress).
- **🛰️ Authority Command Center**: Interactive map overlays using `flutter_map` for geographic outbreak visualization and management.
- **🧪 PulseVelocity Engine**: A multi-pillar scoring logic that synthesizes pharmacy sales data, search intent, and environmental metrics.
- **🔔 Proactive Alerting**: Automated notifications for regional health authorities and citizens based on localized risk thresholds.

---

## 🛠️ Technology Stack

### Frontend (Mobile & Web)
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Design System**: Premium Custom UI with `lucide_icons`, `google_fonts`, and `animations`.
- **Mapping**: `flutter_map` with OpenStreetMap integration.

### Backend & Intelligence
- **Platform**: [Firebase](https://firebase.google.com/) (Firestore, Cloud Functions, Auth)
- **Engine**: Python-based intelligence daemons for risk calculation.
- **External APIs**: [OpenWeather](https://openweathermap.org/) for real-time climate data.

---

## 📂 Project Structure

```text
├── lib/                      # Flutter Frontend logic
│   ├── core/                 # Shared services & notifications
│   ├── features/             # Feature-based modules (Auth, Dashboard, Authority)
│   └── main.dart             # App Entry Point
├── functions/                # Firebase Cloud Functions (Python)
├── pulse_brain_daemon.py     # Background intelligence processor
├── simulate_pulse_data.py    # Mock data generator for stress testing
└── weather_service.py        # Environmental risk calculation module
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Python 3.10+
- Firebase Account & CLI
- OpenWeather API Key

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Chaitanya-18-eng/PlusePoint.git
   cd PlusePoint
   ```

2. **Initialize Flutter**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment**:
   - Create a `service-account.json` in the root for Firebase Admin access (for Python scripts).
   - Update `OPENWEATHER_API_KEY` in `weather_service.py` and `lib/core/services/weather_service.dart`.

4. **Run the Simulation (Optional)**:
   ```bash
   python simulate_pulse_data.py
   ```

5. **Launch the App**:
   ```bash
   flutter run
   ```

---

## 🛡️ Security Note

Sensitive credentials like `service-account.json` and local environment files are ignored by `.gitignore`. Always use environment variables for production deployments.

---

## 📈 Future Roadmap (Scaling)

To take PulsePoint from a localized hackathon prototype to a global health intelligence network, we are focusing on:

- **🤖 AI-Driven Prediction**: Implementing Generative AI (Gemini) to forecast outbreak trajectories based on historical patterns and current environmental shifts.
- **🌍 Global Node Protocol**: Enabling decentralized data sharing between regional authorities using a standardized health-intelligence protocol.

---
