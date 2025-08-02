//
//  APIManager.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import UIKit

class APIManager: ObservableObject {
    internal let geminiAPIKey = "AIzaSyBB9KIbBd5L1-sKvc6EgqsyWERwH9PSmII"
    private let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v0/product"
    internal let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    
    func fetchProductData(barcode: String) async throws -> OpenFoodFactsProduct? {
        print("🔍 Fetching product data for barcode: \(barcode)")
        // Request comprehensive product data including ingredients
        let url = URL(string: "\(openFoodFactsBaseURL)/\(barcode).json?fields=product_name,brands,nutriments,image_url,ingredients,nutrition_grades")!
        
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
            if let ingredients = product.ingredients {
                print("🧪 Ingredients Count: \(ingredients.count)")
                let ingredientTexts = ingredients.compactMap { $0.text }.prefix(3).joined(separator: ", ")
                print("🧪 First 3 Ingredients: \(ingredientTexts)")
            } else {
                print("⚠️ No ingredients data found")
            }
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
        let conditionsText = userProfile.medicalConditions.isEmpty ? "no specific conditions" : userProfile.medicalConditions.joined(separator: ", ")
        
        let productInfo: String
        if let productData = productData {
            let ingredientsList = productData.ingredients?.compactMap { $0.text }.joined(separator: ", ") ?? "Not available"
            
            productInfo = """
            Product Name: \(productData.productName ?? "Unknown")
            Brands: \(productData.brands ?? "Unknown")
            
            INGREDIENTS: \(ingredientsList)
            
            Nutrition per 100g:
            - Energy: \(productData.nutriments?.energy ?? 0) kcal
            - Fat: \(productData.nutriments?.fat ?? 0)g
            - Saturated Fat: \(productData.nutriments?.saturatedFat ?? 0)g
            - Carbohydrates: \(productData.nutriments?.carbohydrates ?? 0)g
            - Sugars: \(productData.nutriments?.sugars ?? 0)g
            - Fiber: \(productData.nutriments?.fiber ?? 0)g
            - Proteins: \(productData.nutriments?.proteins ?? 0)g
            - Salt: \(productData.nutriments?.salt ?? 0)g
            - Sodium: \(productData.nutriments?.sodium ?? 0)mg
            """
        } else {
            productInfo = "Product information not available from barcode database."
        }
        
        return """
        You are a nutrition expert analyzing food products for a health-conscious consumer with specific medical conditions.
        
        Your User Profile:
        - Age: \(userProfile.age)
        - Height: \(userProfile.height)cm
        - Weight: \(userProfile.weight)kg
        - Medical Conditions: \(conditionsText)
        
        Product Information:
        \(productInfo)
        
        IMPORTANT ANALYSIS REQUIREMENTS:
        1. Consider BOTH nutrition facts AND ingredients list for health assessment
        2. Pay special attention to processed ingredients, additives, preservatives
        3. Consider ingredient quality, not just nutritional numbers
        4. Look for concerning ingredients like: high fructose corn syrup, trans fats, artificial colors, excessive sodium, etc.
        5. Factor in your specific medical conditions
        
        CRITICAL TEXT FORMATTING RULES:
        - DO NOT use any markdown formatting (no *, **, _, __, etc.)
        - Write in plain text only
        - Use simple, clear language without special formatting
        - Avoid bold, italic, or any markdown syntax
        
        Please analyze this product comprehensively and provide:
        1. A NutriScore (A, B, C, D, or E) - A being the healthiest, considering BOTH nutrition AND ingredients
        2. 3-5 bullet points explaining why this product is suitable or unsuitable for you (mention specific ingredients/nutrients that concern or benefit you)
        3. 2-3 citations from reputable health sources
        4. A list of ingredients with simple English explanations of what each ingredient is and its purpose/effect
        
        Return your response in this exact JSON format:
        {
            "nutriScore": "C",
            "analysisPoints": [
                "Point about specific ingredients or nutrients relevant to you",
                "Point about how this suits your medical conditions", 
                "Point about processing level and what it means for your health",
                "Point about portion recommendations for you"
            ],
            "citations": [
                "American Heart Association guidelines on sodium intake",
                "WHO recommendations on processed foods"
            ],
            "productName": "\(productData?.productName ?? "Unknown Product")",
            "confidence": 0.85,
            "ingredients": [
                "Water - The base liquid for hydration",
                "Sugar - Provides quick energy but can cause blood sugar spikes",
                "Citric Acid - Natural preservative and flavor enhancer"
            ]
        }
        
        REMEMBER: Use plain text only, no markdown formatting in any text fields.
        """
    }
    
    private func createImageAnalysisPrompt(userProfile: User) -> String {
        let conditionsText = userProfile.medicalConditions.isEmpty ? "no specific conditions" : userProfile.medicalConditions.joined(separator: ", ")
        
        return """
        You are a nutrition expert analyzing food product images for a health-conscious consumer with specific medical conditions.
        
        Your User Profile:
        - Age: \(userProfile.age)
        - Height: \(userProfile.height)cm
        - Weight: \(userProfile.weight)kg
        - Medical Conditions: \(conditionsText)
        
        CRITICAL INSTRUCTIONS FOR IMAGE ANALYSIS:
        1. CAREFULLY READ ALL TEXT in this image including:
           - Nutrition Facts panel (calories, fats, sugars, sodium, etc.)
           - INGREDIENTS LIST (this is crucial - read every ingredient!)
           - Product name and brand
           - Any allergen warnings
           - Any health claims or certifications
        
        2. COMPREHENSIVE HEALTH ASSESSMENT:
           - Base your NutriScore on BOTH nutritional content AND ingredient quality
           - Look for concerning ingredients: artificial additives, preservatives, high fructose corn syrup, trans fats, excessive sodium
           - Consider processing level (ultra-processed vs minimally processed)
           - Factor in your specific medical conditions
        
        3. If you cannot clearly read both nutrition facts AND ingredients, ask for a clearer image
        
        CRITICAL TEXT FORMATTING RULES:
        - DO NOT use any markdown formatting (no *, **, _, __, etc.)
        - Write in plain text only
        - Use simple, clear language without special formatting
        - Avoid bold, italic, or any markdown syntax
        
        Please analyze this product image comprehensively and provide:
        1. A NutriScore (A, B, C, D, or E) - A being the healthiest, considering BOTH nutrition AND ingredients quality
        2. 3-5 bullet points explaining:
           - Specific nutritional concerns or benefits for you
           - Ingredient quality assessment (mention concerning additives/preservatives that affect you)
           - How this suits your medical conditions
           - Processing level and health recommendations for you
        3. 2-3 citations from reputable health sources
        4. A list of ingredients with simple English explanations of what each ingredient is and its purpose/effect (extract from the product image)
        
        Return your response in this exact JSON format:
        {
            "nutriScore": "C",
            "analysisPoints": [
                "Nutritional analysis based on facts panel and how it affects you",
                "Ingredient quality assessment with specific concerns for your health",
                "How this product suits your medical conditions", 
                "Processing level and health recommendations tailored to you"
            ],
            "citations": [
                "Relevant health authority guideline",
                "Scientific study or health organization recommendation"
            ],
            "productName": "Product name from image",
            "confidence": 0.85,
            "ingredients": [
                "Water - The base liquid for hydration",
                "Sugar - Provides quick energy but can cause blood sugar spikes",
                "Citric Acid - Natural preservative and flavor enhancer"
            ]
        }
        
        REMEMBER: Use plain text only, no markdown formatting in any text fields.
        IMPORTANT: Your analysis should be consistent - the same product should get the same NutriScore whether scanned by barcode or image!
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
        var result = try JSONDecoder().decode(GeminiAnalysisResult.self, from: jsonData)
        
        // Clean up any markdown formatting that might have slipped through
        result = cleanMarkdownFormatting(from: result)
        
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
        var result = try JSONDecoder().decode(GeminiAnalysisResult.self, from: jsonData)
        
        // Clean up any markdown formatting that might have slipped through
        result = cleanMarkdownFormatting(from: result)
        
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
    
    private func cleanMarkdownFormatting(from result: GeminiAnalysisResult) -> GeminiAnalysisResult {
        // Clean analysis points
        let cleanedAnalysisPoints = result.analysisPoints.map { point in
            cleanMarkdownFromText(point)
        }
        
        // Clean citations
        let cleanedCitations = result.citations.map { citation in
            cleanMarkdownFromText(citation)
        }
        
        // Clean ingredients
        let cleanedIngredients = result.ingredients?.map { ingredient in
            cleanMarkdownFromText(ingredient)
        }
        
        // Clean product name
        let cleanedProductName = result.productName.map { cleanMarkdownFromText($0) }
        
        return GeminiAnalysisResult(
            nutriScore: result.nutriScore,
            analysisPoints: cleanedAnalysisPoints,
            citations: cleanedCitations,
            productName: cleanedProductName,
            confidence: result.confidence,
            ingredients: cleanedIngredients
        )
    }
    
    private func cleanMarkdownFromText(_ text: String) -> String {
        return text
            // Remove bold formatting
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            // Remove italic formatting
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            // Remove inline code formatting
            .replacingOccurrences(of: "`", with: "")
            // Remove strikethrough
            .replacingOccurrences(of: "~~", with: "")
            // Clean up any double spaces that might result
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
