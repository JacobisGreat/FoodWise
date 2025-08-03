//
//  LoadingView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            AppColors.backgroundWhite
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Simple logo
                ZStack {
                    Circle()
                        .fill(AppColors.primaryGreen.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primaryGreen)
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // Loading text
                Text("Loading...")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                // Simple loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryGreen))
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
}
