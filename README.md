# 🛡️ RouteGuardian

**AI-Powered Community Safety & Navigation Platform**

RouteGuardian is a mobile-first application that empowers communities to report, track, and navigate around safety incidents in real-time. Using crowd-sourced data and **N-ATLaS AI** for intelligent analysis, it helps users make informed decisions about their routes and surroundings.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![N-ATLaS](https://img.shields.io/badge/N--ATLaS-AI%20Powered-00D4FF?style=for-the-badge)

---

## 🧠 N-ATLaS AI Integration

This application is built around the **N-ATLaS (News Article Text Language Analysis System)** model for intelligent incident detection and analysis.

### AI Features

| Feature | Description |
|---------|-------------|
| **Text Analysis** | Analyze any text for safety-related incidents |
| **News URL Processing** | Extract incidents from news article URLs |
| **Severity Assessment** | AI-powered severity scoring (0-100) |
| **Report Verification** | Validate authenticity of user reports |
| **Location Extraction** | Identify locations mentioned in text |

### Model Setup

1. Navigate to the `models/` directory
2. Download the N-ATLaS model from [HuggingFace](https://huggingface.co/QuantFactory/N-ATLaS-GGUF)
3. Place `N-ATLaS.Q4_K_M.gguf` in the `models/` folder

```bash
# Option: Using Python
pip install huggingface_hub
python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='QuantFactory/N-ATLaS-GGUF', filename='N-ATLaS.Q4_K_M.gguf', local_dir='models/')"
```

---

## ✨ Key Features

### 📍 Live Intel Map
- Real-time incident visualization on an interactive map
- Color-coded severity markers (🔴 High Risk, 🟠 Medium, 🟢 Low)
- Heatmap overlay showing high-risk zones
- Filter incidents by type (Robbery, Accident, Harassment, etc.)

### 🧠 N-ATLaS AI Analysis
- Analyze news articles for incident detection
- Text classification and severity scoring
- Multilingual support
- Confidence-based reporting

### 📝 Incident Reporting
- Full-screen location picker with GPS support
- Date and time selection
- Incident type categorization with auto-severity scoring
- Evidence upload (photos, videos)
- News article and social media link attachments
- AI verification badge system

### 🗺️ Smart Navigation
- Route planning with safety awareness
- Avoid high-risk areas automatically
- Turn-by-turn navigation integration ready

### 👤 User Profile
- Account management
- Privacy controls
- Notification preferences
- Anonymous reporting mode
- Activity statistics

### 🔔 Alert System
- Nearby incident notifications
- Customizable alert radius
- Real-time updates

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **AI Model** | N-ATLaS (GGUF format) |
| **Database** | SQLite (sqflite + sqflite_common_ffi) |
| **Maps** | flutter_map (Windows/Desktop) + MapLibre GL (Mobile/Web) |
| **State Management** | Provider |
| **UI Theme** | Custom Cyberpunk/Neon Dark Mode |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Windows/macOS/Linux for desktop, or Android/iOS emulator
- **N-ATLaS model** (for AI features) - see [Model Setup](#model-setup)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mrAhmad47/route_guardian.git
   cd route_guardian
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Download N-ATLaS model** (optional, for AI features)
   ```bash
   cd models
   # Follow instructions in models/README.md
   ```

4. **Run the application**
   
   **Windows Desktop:**
   ```bash
   flutter run -d windows
   ```
   
   **macOS Desktop:**
   ```bash
   flutter run -d macos
   ```
   
   **Android/iOS:**
   ```bash
   flutter run
   ```
   
   **Web:**
   ```bash
   flutter run -d chrome
   ```

---

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| **Home** | Quick access dashboard with safety score |
| **Live Intel Map** | Interactive map with incident markers and heatmap |
| **N-ATLaS AI Analysis** | Text and URL analysis using N-ATLaS model |
| **Report Incident** | Submit new safety incidents with evidence |
| **Alerts** | View all nearby incident notifications |
| **Route Selection** | Plan safe navigation routes |
| **Profile** | User settings and preferences |

---

## 🎯 How It Works

1. **Report** - Users submit incidents with location, description, and evidence
2. **Analyze** - N-ATLaS AI processes text for incident detection and severity
3. **Aggregate** - System collects and categorizes all reported incidents
4. **Verify** - AI validates report authenticity
5. **Visualize** - Heatmaps and markers show risk levels on the map
6. **Navigate** - Users plan routes avoiding high-risk areas

---

## 📁 Project Structure

```
route_guardian/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── components/                  # Reusable UI components
│   │   ├── neon_button.dart
│   │   ├── neon_card.dart
│   │   ├── platform_aware_map.dart
│   │   └── ...
│   ├── models/                      # Data models
│   │   └── incident_report.dart
│   ├── routes/                      # Navigation routes
│   │   └── routes.dart
│   ├── screens/                     # App screens
│   │   ├── home_screen.dart
│   │   ├── premium_map_screen.dart
│   │   ├── ai_analysis_screen.dart  # N-ATLaS integration
│   │   ├── report_incident_screen.dart
│   │   └── ...
│   ├── services/                    # Business logic & data
│   │   ├── natlas_service.dart      # N-ATLaS AI service
│   │   ├── incident_database.dart
│   │   ├── heatmap_service.dart
│   │   └── ...
│   └── theme/                       # App theming
│       └── theme.dart
├── models/                          # AI model directory
│   └── README.md                    # Model download instructions
└── pubspec.yaml
```

---

## 🎨 Design Philosophy

RouteGuardian features a **Cyberpunk-inspired dark theme** with:
- Neon green (#39FF14) and cyan blue (#00D4FF) accent colors
- Glassmorphism cards with subtle transparency
- Glowing effects on interactive elements
- High contrast for accessibility
- Consistent dark backgrounds for reduced eye strain

---

## 🔮 Future Roadmap

- [ ] Full N-ATLaS model inference integration
- [ ] Firebase integration for cloud sync
- [ ] Push notifications for nearby alerts
- [ ] Real-time news scraping and analysis
- [ ] Community verification voting system
- [ ] Offline maps support
- [ ] Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**RouteGuardian Team**

Built for the N-ATLaS AI Competition

---

## 🙏 Acknowledgments

- **N-ATLaS Team** for the powerful language analysis model
- Flutter team for the amazing framework
- OpenStreetMap contributors for map data
- The open-source community for various packages used

---

<p align="center">
  Made with ❤️ for safer communities<br>
  Powered by N-ATLaS AI 🧠
</p>
