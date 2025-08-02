//
//  NutriScoreBadge.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct NutriScoreBadge: View {
    let score: String
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .title
            }
        }
        
        var frameSize: CGSize {
            switch self {
            case .small: return CGSize(width: 30, height: 30)
            case .medium: return CGSize(width: 40, height: 40)
            case .large: return CGSize(width: 80, height: 80)
            }
        }
    }
    
    var body: some View {
        Text(score.uppercased())
            .font(size.fontSize)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: size.frameSize.width, height: size.frameSize.height)
            .background(scoreColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
    
    private var scoreColor: Color {
        switch score.uppercased() {
        case "A":
            return AppColors.nutriScoreA
        case "B":
            return AppColors.nutriScoreB
        case "C":
            return AppColors.nutriScoreC
        case "D":
            return AppColors.nutriScoreD
        case "E":
            return AppColors.nutriScoreE
        default:
            return AppColors.mediumGrayText
        }
    }
}

// MARK: - NutriScore Pills Visualization
struct NutriScorePills: View {
    let score: String
    let style: PillStyle
    
    enum PillStyle {
        case compact, expanded
        
        var pillSize: CGSize {
            switch self {
            case .compact: return CGSize(width: 16, height: 6)
            case .expanded: return CGSize(width: 20, height: 8)
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .compact: return 3
            case .expanded: return 4
            }
        }
    }
    
    private let grades = ["A", "B", "C", "D", "E"]
    
    private var activeIndex: Int {
        grades.firstIndex(of: score.uppercased()) ?? 4 // Default to E if invalid
    }
    
    private func pillColor(at index: Int) -> Color {
        if index > activeIndex {
            return .gray.opacity(0.3)
        }
        
        switch index {
        case 0: return .primaryGreen      // A
        case 1: return .accentTeal        // B
        case 2: return .warning           // C
        case 3: return Color(hex: "#FF7043") // D
        case 4: return .error             // E
        default: return .gray.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: style.spacing) {
            ForEach(0..<grades.count, id: \.self) { index in
                VStack(spacing: 2) {
                    if style == .expanded {
                        Text(grades[index])
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(index <= activeIndex ? pillColor(at: index) : .gray.opacity(0.5))
                    }
                    
                    Capsule()
                        .fill(pillColor(at: index))
                        .frame(width: style.pillSize.width, height: style.pillSize.height)
                        .shadow(color: index <= activeIndex ? pillColor(at: index).opacity(0.3) : .clear, radius: 2)
                }
            }
        }
    }
}

// MARK: - Enhanced NutriScore Card
struct NutriScoreCard: View {
    let score: String
    let productName: String?
    let showDetails: Bool
    
    init(score: String, productName: String? = nil, showDetails: Bool = false) {
        self.score = score
        self.productName = productName
        self.showDetails = showDetails
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NutriScore")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 8) {
                        NutriScoreBadge(score: score, size: .medium)
                        
                        Text(score.uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(scoreTextColor)
                    }
                }
                
                Spacer()
                
                if showDetails {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Grade")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text(gradeDescription)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(scoreTextColor)
                    }
                }
            }
            
            // Pills visualization
            HStack {
                NutriScorePills(score: score, style: showDetails ? .expanded : .compact)
                
                if showDetails {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Better")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        Image(systemName: "arrow.left")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        Text("Worse")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .cardShadow()
    }
    
    private var scoreTextColor: Color {
        switch score.uppercased() {
        case "A": return .primaryGreen
        case "B": return .accentTeal
        case "C": return .warning
        case "D": return Color(hex: "#FF7043")
        case "E": return .error
        default: return .textSecondary
        }
    }
    
    private var gradeDescription: String {
        switch score.uppercased() {
        case "A": return "Excellent"
        case "B": return "Good"
        case "C": return "Fair"
        case "D": return "Poor"
        case "E": return "Bad"
        default: return "Unknown"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Original badges
        HStack(spacing: 15) {
            NutriScoreBadge(score: "A", size: .small)
            NutriScoreBadge(score: "B", size: .medium)
            NutriScoreBadge(score: "C", size: .large)
        }
        
        // Pills visualization
        VStack(spacing: 12) {
            Text("Pills Visualization")
                .font(.headline)
            
            NutriScorePills(score: "A", style: .compact)
            NutriScorePills(score: "C", style: .compact)
            NutriScorePills(score: "E", style: .expanded)
        }
        
        // Enhanced cards
        VStack(spacing: 16) {
            NutriScoreCard(score: "A", productName: "Organic Granola")
            NutriScoreCard(score: "C", productName: "Regular Cereal", showDetails: true)
            NutriScoreCard(score: "E", productName: "Sugary Snack", showDetails: true)
        }
    }
    .padding()
}
