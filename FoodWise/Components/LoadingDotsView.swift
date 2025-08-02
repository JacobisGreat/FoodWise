//
//  LoadingDotsView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct LoadingDotsView: View {
    let color: Color
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: size / 2) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PulsingCircleLoadingView: View {
    let color: Color
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: size + CGFloat(index * 10), height: size + CGFloat(index * 10))
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 0.1 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever()
                            .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }
            
            Circle()
                .fill(color)
                .frame(width: size * 0.4, height: size * 0.4)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingDotsView(color: .primaryGreen, size: 8)
        PulsingCircleLoadingView(color: .primaryGreen, size: 60)
    }
} 