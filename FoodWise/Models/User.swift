//
//  User.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String?
    var name: String
    var email: String
    var age: Int
    var height: Double // in cm
    var weight: Double // in kg
    var medicalConditions: [String]
    var customHealthConditions: [String] // Custom conditions added by user
    var healthGoals: String // Personal health goals and notes
    var additionalHealthConcerns: String // Free-form health concerns
    var createdAt: Date
    
    init(id: String? = nil, name: String, email: String, age: Int, height: Double, weight: Double, medicalConditions: [String] = [], customHealthConditions: [String] = [], healthGoals: String = "", additionalHealthConcerns: String = "") {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.height = height
        self.weight = weight
        self.medicalConditions = medicalConditions
        self.customHealthConditions = customHealthConditions
        self.healthGoals = healthGoals
        self.additionalHealthConcerns = additionalHealthConcerns
        self.createdAt = Date()
    }
}
