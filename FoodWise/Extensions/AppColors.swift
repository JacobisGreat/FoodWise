//
//  AppColors.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct AppColors {
    // Primary Colors
    static let primaryGreen = Color(hex: "#4CAF50")       // Health, vitality, action
    static let accentTeal = Color(hex: "#26A69A")         // Freshness, trust, calm
    static let secondaryTeal = Color(hex: "#26A69A")      // Alias for accentTeal
    
    // Background Colors
    static let backgroundWhite = Color(hex: "#FFFFFF")    // App background
    static let panelOffWhite = Color(hex: "#FAFAFA")      // Cards, light containers
    static let surfaceSecondary = Color(hex: "#F5F5F5")   // Secondary surfaces
    
    // Text Colors
    static let textPrimary = Color(hex: "#212121")        // Primary text
    static let textSecondary = Color(hex: "#757575")      // Secondary text, placeholders
    static let textTertiary = Color(hex: "#9E9E9E")       // Tertiary text
    
    // Structural Colors
    static let dividerGray = Color(hex: "#E0E0E0")        // Borders, dividers
    
    // Status Colors
    static let warning = Color(hex: "#FFC107")            // NutriScore C, gentle warnings
    static let error = Color(hex: "#E53935")              // NutriScore D/E, danger text
    static let infoBlue = Color(hex: "#42A5F5")           // Tips, optional actions
    
    // Convenience aliases for semantic usage
    static let success = primaryGreen
    static let info = infoBlue
}
