//
//  User.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Equatable {
    var id: String?
    var name: String
    var email: String
    var age: Int
    var height: Double // in cm
    var weight: Double // in kg
    var medicalConditions: [String]
    var createdAt: Date
    
    init(id: String? = nil, name: String, email: String, age: Int, height: Double, weight: Double, medicalConditions: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.height = height
        self.weight = weight
        self.medicalConditions = medicalConditions
        self.createdAt = Date()
    }
    
    // Equatable conformance
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.email == rhs.email &&
               lhs.age == rhs.age &&
               lhs.height == rhs.height &&
               lhs.weight == rhs.weight &&
               lhs.medicalConditions == rhs.medicalConditions
        // Note: Excluding createdAt from equality check as it might have slight differences
    }
}
