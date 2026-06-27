# 💇‍♀️ Hey Keshaa - Smart Hair Health Diagnostic System

An IoT-enabled mobile application that integrates with a custom ESP32 hardware comb to provide real-time hair health monitoring, diagnostics, and personalized hair care recommendations.

## 🌟 Problem & Solution

**The Problem:**
- Over 60% of people face hair health issues but lack personalized tracking.
- No real-time, at-home diagnostics exist for hair health.

**Our Solution:**
An IoT-enabled smart comb equipped with:
- **Real-time sensor monitoring** (DHT22 for moisture/temperature, MPU6050 for motion/brushing patterns).
- **AI-powered insights** for real-time hair health scoring.
- **Personalized care recommendations** based on historical trends.

## 🛠️ Technology Stack
- **Frontend App:** Flutter (Android, iOS, Web)
- **Backend Services:** Firebase (Auth, Firestore)
- **Hardware Integration:** ESP32 Microcontroller via Bluetooth Low Energy (BLE)
- **AI/Logic:** Custom algorithms for health scoring

## 🚀 How to Setup and Run (For Teammates)

This project has been modernized to run on the latest Flutter SDK! Follow these steps to get it running on your local machine.

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Install [Android Studio](https://developer.android.com/studio) (for the Android Emulator).
3. Ensure you have Google Chrome installed (for Web testing).

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <YOUR-GITHUB-REPO-URL-HERE>
   cd hey_keshaa
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App!**
   - **For Web (Easiest way to test UI):**
     ```bash
     flutter run -d chrome
     ```
   - **For Android (To test Bluetooth/Hardware):**
     Open the project in Android Studio, select your Android Emulator from the top toolbar, and click the green **Run** button.

### ⚠️ Important Note on Google Sign-In (Android)
If you are testing on an Android Emulator and Google Sign-In fails, you need to add your personal computer's `SHA-1` debug key to the Firebase Console. 
Run this command to get your SHA-1 key:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
Then send it to the project admin to add to Firebase! (Web authentication works out of the box).

## 👥 Team
- [Your Name] - CSE, [College Name]
- [Teammate 1 Name]
- [Teammate 2 Name]

## 🎥 Demo
[Link to Video / Add screenshots here later]
