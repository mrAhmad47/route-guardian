# RouteGuardian 🛡️

**AI-Powered Safety Routing App for Nigeria and Africa**

A Flutter application that helps users find the safest routes by analyzing real-time incidents, news reports, and user submissions using AI-powered risk assessment.

## 🌟 Features

### ✅ Implemented & Working

- **Safe Route Navigation**: Find multiple route alternatives with AI-powered safety scoring
- **Real-time Incident Map**: Interactive explore map showing crime, accidents, and security incidents
- **News Discovery**: Automatic incident detection from Nigeria news sources (last 24 hours)
- **Heatmap Visualization**: 500m radius circles showing incident severity
- **User Reports**: Community-driven incident reporting system
- **N-ATLaS AI Analysis**: Local AI model for safety assessment and severity scoring
- **Platform Auto-Detection**: Seamlessly works on web and mobile

## 🎯 Key Highlights

- **200+ Point Route Polylines**: Routes follow roads accurately with smooth curves
- **24-Hour Incident Filter**: Only shows recent, relevant safety information
- **Offline Routing**: Fallback routing when server unavailable
- **Cross-Platform**: Web (Chrome) and Mobile (Android/iOS) support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0+)
- Python 3.8+ (for N-ATLaS server)
- Google Maps API Key
- NewsAPI Key (optional, for news discovery)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mrAhmad47/route-guardian.git
   cd route-guardian
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Python server**
   ```bash
   pip install llama-cpp-python requests
   python natlas_server.py
   ```

4. **Run on web**
   ```bash
   flutter run -d chrome
   ```

5. **Run on mobile**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Frontend (Flutter)
- **Services**: Directions, News Discovery, Safety Analysis
- **Screens**: Home, Route Selection, Explore Map, Incident Details
- **Platform Detection**: Automatic server URL selection for web/mobile

### Backend (Python)
- **N-ATLaS AI Server**: Llama 3.2 3B model for safety analysis
- **News API Integration**: NewsAPI.org with Google News fallback
- **Directions Proxy**: CORS-enabled Google Directions API proxy

## 📱 Screens

- **Home**: Quick route search with GPS location
- **Route Selection**: Multiple routes with safety scores and warnings
- **Explore Map**: Interactive incident visualization with heatmap
- **Alerts**: Recent incidents and news-based warnings
- **Report**: Community incident submission

## 🔧 Configuration

### API Keys
Add your API keys to `natlas_server.py`:
```python
NEWS_API_KEY = "your_newsapi_key_here"
GOOGLE_MAPS_API_KEY = "your_google_maps_key_here"
```

### Server URLs
The app automatically detects platform:
- **Web**: `http://127.0.0.1:8765`
- **Mobile**: `http://10.227.22.32:8765` (WiFi)

## 📦 Key Packages

```yaml
flutter_polyline_points: ^2.0.1  # Accurate route rendering
google_maps_flutter: ^2.5.0      # Interactive maps
latlong2: ^0.9.0                 # GPS coordinates
http: ^1.6.0                     # API requests
```

## 🎨 Design

- **Theme**: Cybersecurity-inspired dark mode
- **Colors**: Neon green accents with dark backgrounds
- **Font**: Roboto family
- **Style**: Modern, minimalistic, focused on safety

## 🧪 Testing

### Web Testing
```bash
flutter run -d chrome
```

### Mobile Testing
1. Connect phone via USB
2. Enable USB debugging
3. Run: `flutter run`

## 📊 Features Breakdown

| Feature | Status | Description |
|---------|--------|-------------|
| Route Calculation | ✅ | Google Directions with 3 alternatives |
| Safety Scoring | ✅ | AI-powered 0-100 safety scores |
| News Discovery | ✅ | Auto-fetch Nigeria crime news |
| Incident Reporting | ✅ | User submission system |
| Heatmap | ✅ | Visual severity indicators |
| Offline Support | ✅ | Fallback routing |

## 🎯 Future Enhancements

- [ ] Real-time location tracking during navigation
- [ ] Push notifications for route hazards
- [ ] Incident photo uploads
- [ ] Firebase integration for cloud sync
- [ ] Voice navigation with safety alerts

## 📝 License

This project was developed as part of a university/competition submission.

## 👨‍💻 Author

**mrAhmad47**

## 🙏 Acknowledgments

- N-ATLaS (Llama 3.2 3B) for AI safety analysis
- Google Maps Platform for routing and visualization
- NewsAPI.org for incident discovery
- Flutter team for the amazing framework

## 📞 Support

For issues or questions, please [open an issue](https://github.com/mrAhmad47/route-guardian/issues) on GitHub.

---

**Built with ❤️ for safer travel in Nigeria and Africa**
