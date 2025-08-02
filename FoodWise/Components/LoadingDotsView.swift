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
                    .opacity(isAnimating ? 0.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
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

#Preview {
    LoadingDotsView(color: .primaryGreen, size: 8)
} 