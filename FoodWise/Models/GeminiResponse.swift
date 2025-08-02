//
//  GeminiResponse.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiAnalysisResult: Codable {
    let nutriScore: String
    let analysisPoints: [String]
    let citations: [String]
    let productName: String?
    let confidence: Double?
}
