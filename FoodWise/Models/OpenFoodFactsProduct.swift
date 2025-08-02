//
//  OpenFoodFactsProduct.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

struct OpenFoodFactsProduct: Codable {
    let productName: String?
    let brands: String?
    let nutriments: Nutriments?
    let imageUrl: String?
    let ingredients: [Ingredient]?
    let nutritionGrades: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
        case imageUrl = "image_url"
        case ingredients = "ingredients"
        case nutritionGrades = "nutrition_grades"
    }
}

struct Nutriments: Codable {
    let energy: Double?
    let fat: Double?
    let saturatedFat: Double?
    let carbohydrates: Double?
    let sugars: Double?
    let fiber: Double?
    let proteins: Double?
    let salt: Double?
    let sodium: Double?
    
    enum CodingKeys: String, CodingKey {
        case energy = "energy-kcal_100g"
        case fat = "fat_100g"
        case saturatedFat = "saturated-fat_100g"
        case carbohydrates = "carbohydrates_100g"
        case sugars = "sugars_100g"
        case fiber = "fiber_100g"
        case proteins = "proteins_100g"
        case salt = "salt_100g"
        case sodium = "sodium_100g"
    }
}

struct Ingredient: Codable {
    let id: String?
    let text: String?
    let rank: Int?
}
