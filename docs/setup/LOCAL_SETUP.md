# Local Development Setup Guide

This guide walks you through setting up both the Student Mobile App and Admin Web Panel on your local workstation.

---

## Prerequisites

1. **Flutter SDK**: 3.24.x or higher ([Flutter Install Guide](https://docs.flutter.dev/get-started/install))
2. **Dart SDK**: 3.5.x or higher
3. **Android Studio / VS Code** with Flutter and Dart extensions
4. **Chrome / Edge Browser** for running the Flutter Web Admin Panel
5. **Git**

---

## 1. Student App Setup (`student-app/`)

### Step 1: Navigate and install dependencies
```bash
cd student-app
flutter pub get
```

### Step 2: Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Update `.env` with your Supabase URL and Anon Key:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
RAZORPAY_KEY_ID=rzp_test_your_key_id
```

### Step 3: Run the Application
Launch an Android emulator or connect a physical Android device:
```bash
flutter run
```

---

## 2. Admin Panel Setup (`admin-panel/`)

### Step 1: Navigate and install dependencies
```bash
cd admin-panel
flutter pub get
```

### Step 2: Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

### Step 3: Run on Chrome
```bash
flutter run -d chrome
```

---

## 3. Running Static Code Quality & Analysis
```bash
# Student App
cd student-app
flutter analyze
flutter test

# Admin Panel
cd admin-panel
flutter analyze
flutter test
```
