//
//  ScanResult.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseFirestore

struct ScanResult: Codable, Identifiable {
    var id: String?
    var userId: String
    var productName: String
    var productImage: String?
    var nutriScore: String // A, B, C, D, E
    var analysisPoints: [String]
    var citations: [String]
    var scannedAt: Date
    var barcode: String?
    
    init(id: String? = nil, userId: String, productName: String, productImage: String? = nil, nutriScore: String, analysisPoints: [String], citations: [String], barcode: String? = nil) {
        self.id = id
        self.userId = userId
        self.productName = productName
        self.productImage = productImage
        self.nutriScore = nutriScore
        self.analysisPoints = analysisPoints
        self.citations = citations
        self.scannedAt = Date()
        self.barcode = barcode
    }
}
