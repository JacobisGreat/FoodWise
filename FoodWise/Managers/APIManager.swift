//
//  APIManager.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import UIKit

class APIManager: ObservableObject {
    private let geminiAPIKey = "AIzaSyDh4PSJ5QTZVqAcA9PVhSRs1uylVZYyZHU"
    private let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v0/product"
    private let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func fetchProductData(barcode: String) async throws -> OpenFoodFactsProduct? {
        print("🔍 Fetching product data for barcode: \(barcode)")
        let url = URL(string: "\(openFoodFactsBaseURL)/\(barcode).json")!
        
        print("📡 Open Food Facts URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Open Food Facts Response Status: \(httpResponse.statusCode)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("📦 Open Food Facts Raw Response: \(responseString.prefix(500))...")
        
        let decodedResponse = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
        print("✅ Open Food Facts Response Status: \(decodedResponse.status)")
        
        if let product = decodedResponse.product {
            print("🥫 Product Found: \(product.productName ?? "Unknown")")
            print("🏷️ Brands: \(product.brands ?? "Unknown")")
            if let nutriments = product.nutriments {
                print("🧮 Nutrition - Energy: \(nutriments.energy ?? 0) kcal, Fat: \(nutriments.fat ?? 0)g, Carbs: \(nutriments.carbohydrates ?? 0)g")
            }
        } else {
            print("❌ No product found for barcode: \(barcode)")
        }
        
        return decodedResponse.product
    }
    
    func analyzeWithGemini(productData: OpenFoodFactsProduct?, userProfile: User) async throws -> GeminiAnalysisResult {
        print("🤖 Starting Gemini analysis for barcode product")
        let prompt = createAnalysisPrompt(productData: productData, userProfile: userProfile)
        print("📝 Gemini Prompt (first 300 chars): \(prompt.prefix(300))...")
        return try await sendGeminiRequest(prompt: prompt)
    }
    
    func analyzeImageWithGemini(image: UIImage, userProfile: User) async throws -> GeminiAnalysisResult {
        print("🤖 Starting Gemini image analysis")
        let prompt = createImageAnalysisPrompt(userProfile: userProfile)
        print("📝 Gemini Image Prompt (first 300 chars): \(prompt.prefix(300))...")
        return try await sendGeminiImageRequest(prompt: prompt, image: image)
    }
    
    private func createAnalysisPrompt(productData: OpenFoodFactsProduct?, userProfile: User) -> String {
        // Build health conditions list
        var allConditions: [String] = []
        if !userProfile.medicalConditions.isEmpty {
            allConditions.append(contentsOf: userProfile.medicalConditions)
        }
        if !userProfile.customHealthConditions.isEmpty {
            allConditions.append(contentsOf: userProfile.customHealthConditions)
        }
        let conditionsText = allConditions.isEmpty ? "no specific medical conditions" : allConditions.joined(separator: ", ")
        
        // Build health goals and concerns
        let healthGoalsText = userProfile.healthGoals.isEmpty ? "" : "\n- Health Goals: \(userProfile.healthGoals)"
        let healthConcernsText = userProfile.additionalHealthConcerns.isEmpty ? "" : "\n- Additional Health Concerns: \(userProfile.additionalHealthConcerns)"
        
        let productInfo = """
        Product Name: \(productData?.productName ?? "Unknown")
        Brands: \(productData?.brands ?? "Unknown")
        Nutrition per 100g:
        - Energy: \(productData?.nutriments?.energy ?? 0) kcal
        - Fat: \(productData?.nutriments?.fat ?? 0)g
        - Saturated Fat: \(productData?.nutriments?.saturatedFat ?? 0)g
        - Carbohydrates: \(productData?.nutriments?.carbohydrates ?? 0)g
        - Sugars: \(productData?.nutriments?.sugars ?? 0)g
        - Fiber: \(productData?.nutriments?.fiber ?? 0)g
        - Proteins: \(productData?.nutriments?.proteins ?? 0)g
        - Salt: \(productData?.nutriments?.salt ?? 0)g
        """
        
        return """
        You are a personalized nutrition expert speaking directly to a user about their food choices.
        
        User Profile:
        - Age: \(userProfile.age) years old
        - Height: \(userProfile.height)cm
        - Weight: \(userProfile.weight)kg
        - Medical Conditions: \(conditionsText)\(healthGoalsText)\(healthConcernsText)
        
        Product Information:
        \(productInfo)
        
        Analyze this product specifically for this user and provide personalized feedback. Speak directly to them using "you" and "your". Consider their health goals, medical conditions, and concerns when making recommendations.
        
        Provide:
        1. A NutriScore (A, B, C, D, or E) - A being the healthiest
        2. 3-5 bullet points explaining how this product fits with their health goals and conditions (speak directly to them)
        3. 2-3 citations from reputable health sources (WHO, Mayo Clinic, Harvard Health, etc.)
        
        Return your response in this exact JSON format:
        {
            "nutriScore": "A",
            "analysisPoints": ["Point 1", "Point 2", "Point 3"],
            "citations": ["Citation 1", "Citation 2"],
            "productName": "Product Name",
            "confidence": 0.95
        }
        """
    }
    
    private func createImageAnalysisPrompt(userProfile: User) -> String {
        // Build health conditions list
        var allConditions: [String] = []
        if !userProfile.medicalConditions.isEmpty {
            allConditions.append(contentsOf: userProfile.medicalConditions)
        }
        if !userProfile.customHealthConditions.isEmpty {
            allConditions.append(contentsOf: userProfile.customHealthConditions)
        }
        let conditionsText = allConditions.isEmpty ? "no specific medical conditions" : allConditions.joined(separator: ", ")
        
        // Build health goals and concerns
        let healthGoalsText = userProfile.healthGoals.isEmpty ? "" : "\n- Health Goals: \(userProfile.healthGoals)"
        let healthConcernsText = userProfile.additionalHealthConcerns.isEmpty ? "" : "\n- Additional Health Concerns: \(userProfile.additionalHealthConcerns)"
        
        return """
        You are a personalized nutrition expert with OCR capabilities. Analyze the nutrition label in this image and provide personalized feedback.
        
        User Profile:
        - Age: \(userProfile.age) years old
        - Height: \(userProfile.height)cm
        - Weight: \(userProfile.weight)kg
        - Medical Conditions: \(conditionsText)\(healthGoalsText)\(healthConcernsText)
        
        Please:
        1. Extract the product name and nutrition information from the image
        2. Provide a NutriScore (A, B, C, D, or E) based on nutritional quality
        3. Give 3-5 bullet points explaining how this product aligns with their health goals and conditions (speak directly to them using "you" and "your")
        4. Include 2-3 citations from reputable health sources (WHO, Mayo Clinic, Harvard Health, etc.)
        
        Consider their personal health goals and conditions when making recommendations. Speak directly to them, not about them.
        
        Return your response in this exact JSON format:
        {
            "nutriScore": "A",
            "analysisPoints": ["Point 1", "Point 2", "Point 3"],
            "citations": ["Citation 1", "Citation 2"],
            "productName": "Product Name",
            "confidence": 0.95
        }
        """
    }
    
    private func sendGeminiRequest(prompt: String) async throws -> GeminiAnalysisResult {
        print("🚀 Sending Gemini API request...")
        let url = URL(string: "\(geminiBaseURL)?key=\(geminiAPIKey)")!
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 1000
            ]
        ]
        
        print("📤 Gemini Request Body: \(requestBody)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Gemini Response Status: \(httpResponse.statusCode)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("📦 Gemini Raw Response: \(responseString)")
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let responseText = geminiResponse.candidates.first?.content.parts.first?.text else {
            print("❌ No response text from Gemini")
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from Gemini"])
        }
        
        print("🧠 Gemini Response Text: \(responseText)")
        
        // Parse JSON from response
        let jsonString = extractJSON(from: responseText)
        print("🔍 Extracted JSON: \(jsonString)")
        
        let jsonData = jsonString.data(using: .utf8)!
        let result = try JSONDecoder().decode(GeminiAnalysisResult.self, from: jsonData)
        
        print("✅ Gemini Analysis Complete - NutriScore: \(result.nutriScore), Points: \(result.analysisPoints.count)")
        
        return result
    }
    
    private func sendGeminiImageRequest(prompt: String, image: UIImage) async throws -> GeminiAnalysisResult {
        print("🖼️ Sending Gemini image analysis request...")
        let url = URL(string: "\(geminiBaseURL)?key=\(geminiAPIKey)")!
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let imageSizeKB = Double(imageData.count) / 1024.0
        print("📸 Image size: \(String(format: "%.1f", imageSizeKB)) KB")
        
        let base64Image = imageData.base64EncodedString()
        print("🔢 Base64 image length: \(base64Image.count) characters")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 1000
            ]
        ]
        
        print("📤 Gemini Image Request prepared (excluding base64 data)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Gemini Image Response Status: \(httpResponse.statusCode)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("📦 Gemini Image Raw Response: \(responseString)")
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let responseText = geminiResponse.candidates.first?.content.parts.first?.text else {
            print("❌ No response text from Gemini image analysis")
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from Gemini"])
        }
        
        print("🧠 Gemini Image Response Text: \(responseText)")
        
        // Extract JSON from response text (it might be wrapped in markdown)
        let jsonString = extractJSON(from: responseText)
        print("🔍 Extracted JSON from image analysis: \(jsonString)")
        
        let jsonData = jsonString.data(using: .utf8)!
        let result = try JSONDecoder().decode(GeminiAnalysisResult.self, from: jsonData)
        
        print("✅ Gemini Image Analysis Complete - NutriScore: \(result.nutriScore), Points: \(result.analysisPoints.count)")
        
        return result
    }
    
    private func extractJSON(from text: String) -> String {
        print("🔍 Extracting JSON from text: \(text)")
        
        // Remove markdown code blocks if present
        var cleanedText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON object boundaries
        if let startIndex = cleanedText.firstIndex(of: "{"),
           let endIndex = cleanedText.lastIndex(of: "}") {
            cleanedText = String(cleanedText[startIndex...endIndex])
        }
        
        print("🧹 Cleaned JSON text: \(cleanedText)")
        
        return cleanedText
    }
}
