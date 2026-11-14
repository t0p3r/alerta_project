# ALERTA - Disaster Emergency & DRRMO Response (Flutter / Android)

This repository contains the complete production-grade Flutter source code for **ALERTA**, built for Municipal Disaster Risk Reduction & Management Offices (MDRRMO), PNP, BFP, and citizen emergency reporting.

---

### Prerequisites
- **Flutter SDK**: >= 3.2.0 (`flutter --version`)
- **Android Studio** (Flamingo, Giraffe, Iguana, or Koala) or **VS Code** with Flutter & Dart extensions
- **Google Maps API Key** (Directions & Geolocation)
- **Firebase Project** (Firestore & Firebase Cloud Messaging FCM)

---

### Quick Setup Steps

1. **Extract and Open the Project**:
   Open this folder in VS Code or Android Studio.

2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project at https://console.firebase.google.com
   - Register an Android App with package name: `com.drrmo.alerta`
   - Download `google-services.json` and place it into `android/app/google-services.json`
   - Enable **Cloud Firestore** and **Firebase Cloud Messaging**.

4. **Google Maps Setup**:
   - In `android/app/build.gradle`, replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your Google Cloud Maps SDK key.

5. **Run in Android Studio / VS Code**:
   - Connect your Android device via USB debugging or start an Android Emulator.
   - Run:
     ```bash
     flutter run
     ```

---

### Key Capabilities
- **PAGASA Alerts**: Tropical Cyclone Wind Signals 1-5, Red/Orange/Yellow Heavy Rainfall advisories.
- **Incident Reporting**: Real-time flood levels, impassable road clearing requests, and medical/rescue triage.
- **Evacuation Center Locator**: Live occupancy percentages, facility filters, and one-tap Google Maps directions.
- **Emergency Dispatch Contacts**: Direct dialer for 911, MDRRMO, PNP, BFP, Ambulance EMS, PCG, and Red Cross.
- **PHIVOLCS Mayon Volcano Alert**: Active Alert Level 3 status card, 6-km Permanent Danger Zone warning, and PHIVOLCS direct hotline.
