//
//  DesignSystem.swift
//  FoodWise// MARK: - Typography (Friendly & Relaxing)
extension Font {
    // Friendly, rounded typography
    static let titleLarge = Font.system(size: 28, weight: .medium, design: .rounded)
    static let titleMedium = Font.system(size: 22, weight: .medium, design: .rounded)
    static let titleSmall = Font.system(size: 18, weight: .medium, design: .rounded)
    
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
    
    static let labelLarge = Font.system(size: 16, weight: .medium, design: .rounded)
    static let labelMedium = Font.system(size: 14, weight: .medium, design: .rounded)
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .rounded)
    
    // Special friendly fonts for headers
    static let welcomeTitle = Font.system(size: 26, weight: .medium, design: .rounded)
    static let sectionHeader = Font.system(size: 20, weight: .medium, design: .rounded)
}// ed by Aditya Makhija on 2025-08-02.
//

import SwiftUI

// MARK: - Color Scheme (FoodWise Professional Palette)
extension Color {
    // Primary Colors
    static let primaryGreen = Color(hex: "#4CAF50")       // Health, vitality, action
    static let accentTeal = Color(hex: "#26A69A")         // Freshness, trust, calm
    
    // Background Colors
    static let backgroundWhite = Color(hex: "#FFFFFF")    // App background
    static let panelOffWhite = Color(hex: "#FAFAFA")      // Cards, light containers
    
    // Text Colors
    static let darkTextGray = Color(hex: "#212121")       // Primary text
    static let labelGray = Color(hex: "#757575")          // Secondary text, placeholders
    
    // Structural Colors
    static let dividerGray = Color(hex: "#E0E0E0")        // Borders, dividers
    
    // Status Colors
    static let alertAmber = Color(hex: "#FFC107")         // NutriScore C, gentle warnings
    static let alertRed = Color(hex: "#E53935")           // NutriScore D/E, danger text
    static let infoBlue = Color(hex: "#42A5F5")           // Tips, optional actions
    
    // Convenience aliases for semantic usage
    static let backgroundLight = backgroundWhite
    static let backgroundSoft = panelOffWhite
    static let cardBackground = backgroundWhite
    static let textPrimary = darkTextGray
    static let textSecondary = labelGray
    static let textTertiary = labelGray.opacity(0.7)
    static let primaryGreenLight = primaryGreen.opacity(0.8)
    static let primaryGreenDark = primaryGreen.opacity(1.2)
    static let success = primaryGreen
    static let warning = alertAmber
    static let error = alertRed
    static let info = infoBlue
}

// MARK: - Shadows and Effects
extension View {
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func softShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    func buttonShadow() -> some View {
        self.shadow(color: Color.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.labelLarge)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primaryGreen)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .buttonShadow()
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.labelLarge)
            .foregroundColor(.primaryGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.dividerGray, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    
    init(size: CGFloat = 56) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .medium))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [Color.primaryGreenLight, Color.primaryGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(size / 4)
            .buttonShadow()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Custom Card Style
struct FoodWiseCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(20)
            .cardShadow()
    }
}
