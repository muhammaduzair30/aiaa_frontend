<div align="center">
  <h1>🚀 AIAA (AI Job Application Agent)</h1>
  <p><b>An intelligent, Flutter-based career companion powered by the Gemini API</b></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-Frontend-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-Proprietary-blue.svg)](#)
</div>

---

## 📖 Overview

AIAA is a mobile application engineered to streamline the job application process by integrating advanced AI capabilities directly into the user's workflow. Built with **Flutter** and powered by a custom backend utilizing the **Gemini API**, AIAA provides intelligent insights, resume-to-job matching, and automated cover letter generation. 

Our goal is to provide **technical transparency** and a high-integrity architecture. We focus on deterministic API interactions, robust state management, and real-time processing to give users a competitive edge without relying on misleading marketing buzzwords.

## ✨ Key Features

- **📄 Robust CV Management**: Securely upload, parse, and maintain multiple versions of your resume.
- **🌐 Automated Job Extraction**: Seamlessly import job descriptions directly via URL. Our system utilizes a robust, tiered extraction architecture to parse job details from supported platforms, minimizing manual data entry.
- **🔍 Intelligent Job Analysis**: Compare your CV against specific job descriptions. Our system leverages advanced prompt engineering with the Gemini API to analyze semantic similarities, identify critical skill gaps, and provide an actionable match score.
- **✍️ Automated Cover Letters**: Generate highly tailored, professional cover letters instantly, based on the specific context of your CV and the target job description.
- **📊 Application Pipeline Tracking**: Manage your entire job hunt lifecycle across distinct stages (Saved, Applied, Interview, Offer, Rejected).
- **💾 Persistent Analysis History**: Retrieve and review previous AI insights, match scores, and generated documents anytime.
- **🔒 Secure Authentication**: Ensure privacy and personalized data access with robust, secure authentication flows.

## 🏗️ Architecture & Technical Precision

AIAA is built on a clean, scalable architecture:

- **Frontend (Flutter)**: Implements the **BLoC/Cubit** pattern for predictable state management. Navigation is handled by **GoRouter** for seamless deep-linking and routing. 
- **Networking**: Utilizes **Dio** for robust HTTP requests, including custom interceptors for automatic token refreshing and error handling.
- **Local Storage**: Employs **Flutter Secure Storage** for encrypting sensitive user data (like auth tokens) on the device.
- **AI Integration**: Instead of complex RAG architectures, AIAA utilizes highly-optimized, zero-shot and few-shot prompt engineering directed at the Gemini API to compute contextual match scores and extract actionable insights.

## 🛠️ Tech Stack

### Frontend Core
- **Framework**: Flutter (Dart)
- **State Management**: `flutter_bloc` / Cubit
- **Routing**: `go_router`
- **Networking**: `dio`
- **Dependency Injection**: `get_it`

### UI & Assets
- **Theming**: Custom Material 3 implementation
- **Typography**: Google Fonts
- **Icons**: Phosphor Icons / Material Icons

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your local development environment:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Android Studio or Visual Studio Code with Flutter extensions
- A running instance of the AIAA Backend API

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/muhammaduzair30/aiaa_frontend.git
   cd aiaa_frontend
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration**
   Create a `.env` file in the root directory and add your backend API URL:
   ```env
   BASE_URL=https://your-api-url.com/api/v1
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

## 📂 Project Structure

AIAA adheres to a feature-first architectural pattern to ensure scalability and separation of concerns:

```text
lib/
├── core/             # Core application utilities (routing, theme, network, errors)
├── features/         # Feature modules
│   ├── auth/         # Authentication flow and session management
│   ├── cv/           # Resume uploading, parsing, and management
│   ├── job/          # Job tracking and detail views
│   └── analysis/     # AI matching, scoring, and cover letter generation
├── shared/           # Reusable UI components (buttons, text fields, loaders)
└── main.dart         # Application entry point
```

## 🤝 Contributing

I welcome contributions! If you'd like to help improve AIAA:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## 📝 License

Copyright © 2026 AI Job Application Agent.  
This project is proprietary and confidential unless otherwise specified.
