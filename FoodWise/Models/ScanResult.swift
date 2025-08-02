//
//  ScanResult.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseFirestore

struct ScanResult: Codable, Identifiable, Equatable {
    var id: String?
    var userId: String
    var productName: String
    var productImage: String?
    var nutriScore: String // A, B, C, D, E
    var analysisPoints: [String]
    var citations: [String]
    var scannedAt: Date
    var barcode: String?
    var ingredients: [String]?
    
    init(id: String? = nil, userId: String, productName: String, productImage: String? = nil, nutriScore: String, analysisPoints: [String], citations: [String], barcode: String? = nil, ingredients: [String]? = nil, scannedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.productName = productName
        self.productImage = productImage
        self.nutriScore = nutriScore
        self.analysisPoints = analysisPoints
        self.citations = citations
        self.scannedAt = scannedAt
        self.barcode = barcode
        self.ingredients = ingredients
    }
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        return lhs.id == rhs.id && lhs.scannedAt == rhs.scannedAt
    }
}
