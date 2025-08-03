🍏 FoodWise – Smart Nutrition Scanner for iOS

A healthcare-focused iOS app built in Swift that helps users make informed food choices through barcode scanning and AI-driven analysis.

📖 Overview
FoodWise empowers users, especially those with chronic health conditions, to make healthier food decisions. Simply scan a product's barcode or nutrition label, and the app will analyze it using Open Food Facts and Google Gemini AI. Users receive a personalized NutriScore, detailed bullet points on safety, and small citations from reputable health sources.

✨ Features
📱 Native iOS app built with SwiftUI for seamless performance
🔐 Firebase Authentication for secure sign-in and profile management
📊 Personalized NutriScore based on age, height, weight, and medical conditions
📸 Barcode scanning (local) and label scanning (cloud OCR)
☁️ Cloud AI Analysis with Gemini for suitability evaluation
🧾 Detailed bullet points explaining why food is safe or risky
📚 Cited medical references for credibility
🕒 Scan History to review previous results
🎨 Clean, healthcare-themed UI (Green and White)

🛠️ Tech Stack
Language: Swift (latest)
Framework: SwiftUI
Backend: Firebase (Auth, Firestore, Storage, Cloud Functions)
Barcode Scanner: AVFoundation or VisionKit
Nutrition Data: Open Food Facts API
AI Engine: Google Gemini (OCR and Nutrition Analysis)
Package Manager: Swift Package Manager (SPM)

🧠 Architecture
Pattern: MVVM ensuring separation of concerns and testability
SwiftUI Components: Reusable UI elements for buttons, NutriScore badge, input fields
Services Layer: Handles API communication with Open Food Facts and Gemini AI
Firebase Integration:
Authentication for user profiles
Firestore for storing profile data and scan history
Cloud Functions for secure backend logic
Local Barcode Scanning: Uses on-device frameworks for speed and privacy
Cloud OCR: Performed by Gemini when barcode data is not available
Data Flow: User scans product → Local barcode detection → API fetch or image upload → Gemini analysis → NutriScore and analysis displayed → History saved in Firestore

📜 License
This project is licensed under the MIT License.
You are free to use, modify, and distribute this software for personal or commercial purposes. 
See the LICENSE file for full text.
