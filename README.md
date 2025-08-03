# 🍏 FoodWise – Smart Nutrition Scanner for iOS  

### *Discover what's in your food.*  

---

![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift)  
![iOS](https://img.shields.io/badge/iOS-16%2B-lightgrey?style=for-the-badge&logo=apple)  
![Firebase](https://img.shields.io/badge/Firebase-Authentication%2C%20Firestore%2C%20Storage-ffca28?style=for-the-badge&logo=firebase)  
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-AI%20Analysis-blue?style=for-the-badge&logo=google)  
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)  

---

## 📖 Overview

**FoodWise** empowers users, especially those with chronic health conditions, to make healthier food decisions. Simply scan a product's barcode or nutrition label, and the app will analyze it using **Open Food Facts** and **Google Gemini AI**. Users receive a **personalized NutriScore**, detailed bullet points on safety, and small citations from reputable health sources.  

Additionally, FoodWise features an **AI Nutrition Chatbot** where users can ask anything about health, nutrition, diet planning, or food safety, receiving instant, AI-powered guidance.

---

## ✨ Features

- 📱 **Native iOS app** built with SwiftUI for seamless performance  
- 🔐 **Firebase Authentication** for secure sign-in and profile management  
- 📊 **Personalized NutriScore** based on age, height, weight, and medical conditions  
- 📸 **Barcode scanning** (local) and **label scanning** (cloud OCR)  
- ☁️ **Cloud AI Analysis** with Gemini for suitability evaluation  
- 🤖 **AI Nutrition Chatbot** to answer user questions about health, diet, and nutrition  
- 🧾 **Detailed bullet points** explaining why food is safe or risky  
- 📚 **Cited medical references** for credibility  
- 🕒 **Scan History** to review previous results  
- 🎨 **Clean, healthcare-themed UI** (Green and White)  

---

## 🛠️ Tech Stack

- **Language:** Swift (latest)  
- **Framework:** SwiftUI  
- **Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)  
- **Barcode Scanner:** AVFoundation or VisionKit  
- **Nutrition Data:** [Open Food Facts API](https://world.openfoodfacts.org/data)  
- **AI Engine:** Google Gemini (OCR, Nutrition Analysis, and Chatbot)  
- **Package Manager:** Swift Package Manager (SPM)  

---

## 🧠 Architecture

- **Pattern:** MVVM ensuring separation of concerns and testability  
- **SwiftUI Components:** Reusable UI elements for buttons, NutriScore badge, input fields, and chatbot interface  
- **Services Layer:** Handles API communication with Open Food Facts and Gemini AI  
- **Firebase Integration:**  
  - Authentication for user profiles  
  - Firestore for storing profile data and scan history  
  - Cloud Functions for secure backend logic  
- **Local Barcode Scanning:** Uses on-device frameworks for speed and privacy  
- **Cloud OCR:** Performed by Gemini when barcode data is not available  
- **AI Chatbot:** Uses Gemini for conversational Q&A about nutrition and health  

---

## 🔄 Data Flow

### For barcode scans:
`User scans product → Barcode detected locally → Open Food Facts API fetches product information → Gemini analyzes data with user profile → NutriScore and bullet point analysis generated → Result displayed to user → Saved in Firestore for history`

### For non-barcode scans:
`User takes product image → Image uploaded to backend → Gemini performs OCR to extract nutrition facts and ingredients → Data analyzed with user profile → NutriScore and bullet point analysis generated → Result displayed to user → Saved in Firestore for history`

### For AI Nutrition Chatbot:
`User opens chatbot → Asks health or nutrition question → Gemini processes query → AI chatbot returns instant, medically-referenced guidance`

---

## 📜 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute this software for personal or commercial purposes.  
See the [LICENSE](LICENSE) file for full text.
