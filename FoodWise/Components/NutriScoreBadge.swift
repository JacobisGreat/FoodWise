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

#Preview {
    VStack(spacing: 20) {
        NutriScoreBadge(score: "A", size: .small)
        NutriScoreBadge(score: "B", size: .medium)
        NutriScoreBadge(score: "C", size: .large)
    }
}
