//
//  LoadingView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct LoadingView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.6
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var showPulse = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.backgroundLight,
                    Color.backgroundSoft,
                    Color.primaryGreenLight.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background elements
            ForEach(0..<6) { index in
                Circle()
                    .fill(Color.primaryGreen.opacity(0.05))
                    .frame(width: CGFloat.random(in: 40...120))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true),
                        value: showPulse
                    )
                    .scaleEffect(showPulse ? 1.2 : 0.8)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo section
                VStack(spacing: 24) {
                    // Main logo circle with app icon
                    ZStack {
                        // Pulsing background
                        PulsingCircle(color: .primaryGreenLight, size: 140)
                        
                        // Logo container
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreenLight, Color.primaryGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                // App icon - leaf/food symbol
                                ZStack {
                                    // Leaf shape
                                    Path { path in
                                        path.move(to: CGPoint(x: 30, y: 50))
                                        path.addQuadCurve(
                                            to: CGPoint(x: 70, y: 30),
                                            control: CGPoint(x: 50, y: 25)
                                        )
                                        path.addQuadCurve(
                                            to: CGPoint(x: 70, y: 70),
                                            control: CGPoint(x: 75, y: 50)
                                        )
                                        path.addQuadCurve(
                                            to: CGPoint(x: 30, y: 50),
                                            control: CGPoint(x: 50, y: 75)
                                        )
                                    }
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                    
                                    // Stem
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 2, height: 15)
                                        .offset(x: -10, y: 15)
                                }
                            )
                            .shadow(color: Color.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App name
                    Text("FoodWise")
                        .font(.custom("SF Pro Display", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                        .offset(y: textOffset)
                        .opacity(textOpacity)
                }
                
                Spacer()
                
                // Loading indicator section
                VStack(spacing: 16) {
                    // Custom loading animation
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primaryGreen)
                                .frame(width: 8, height: 24)
                                .scaleEffect(y: showPulse ? 1.5 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: showPulse
                                )
                        }
                    }
                    
                    Text("Preparing your nutrition assistant...")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .opacity(textOpacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        // Logo entrance animation
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text entrance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }
        
        // Start pulsing animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showPulse = true
        }
    }
}

#Preview {
    LoadingView()
}
