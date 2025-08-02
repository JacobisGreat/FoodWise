//
//  WelcomeView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isAnimating = false
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.primaryGreen,
                    AppColors.secondaryTeal.opacity(0.8),
                    AppColors.primaryGreen.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Floating Food Icons Background
            if showParticles {
                FloatingFoodIcons()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // App Icon Animation
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                    
                    // App Name
                    VStack(spacing: 8) {
                        Text("FoodWise")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .tracking(-2.0)
                            .foregroundColor(.white)
                            .opacity(isAnimating ? 1 : 0)
                            .blur(radius: isAnimating ? 0 : 8)
                            .offset(y: isAnimating ? 0 : -40)
                            .animation(.easeOut(duration: 1.0).delay(0.4), value: isAnimating)
                        
                        Text("Smart nutrition analysis for healthier choices")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .opacity(isAnimating ? 1 : 0)
                            .blur(radius: isAnimating ? 0 : 4)
                            .offset(y: isAnimating ? 0 : -20)
                            .animation(.easeOut(duration: 1.0).delay(0.7), value: isAnimating)
                    }
                }
                
                Spacer()
                
                // Feature Highlights
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "camera.fill",
                        title: "Scan & Analyze",
                        subtitle: "Instant nutrition insights",
                        delay: 1.0,
                        isAnimating: isAnimating
                    )
                    
                    FeatureRow(
                        icon: "heart.fill",
                        title: "Personalized Health",
                        subtitle: "Tailored to your medical needs",
                        delay: 1.2,
                        isAnimating: isAnimating
                    )
                    
                    FeatureRow(
                        icon: "clock.fill",
                        title: "Track History",
                        subtitle: "Monitor your nutrition journey",
                        delay: 1.4,
                        isAnimating: isAnimating
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        // Navigate to main app
                    } label: {
                        HStack {
                            Text("Start Scanning")
                                .foregroundColor(AppColors.primaryGreen)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.primaryGreen)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.6), value: isAnimating)
                    
                    Button {
                        // Show login
                    } label: {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .underline()
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(1.8), value: isAnimating)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showParticles = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let delay: Double
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.2))
                .cornerRadius(24)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: isAnimating)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(x: isAnimating ? 0 : -50)
        .animation(.easeOut(duration: 0.8).delay(delay), value: isAnimating)
    }
}

struct FloatingFoodIcons: View {
    @State private var animate1 = false
    @State private var animate2 = false
    @State private var animate3 = false
    
    let foodIcons = ["🍎", "🥕", "🥬", "🫐", "🥑", "🍊"]
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Text(foodIcons[index])
                    .font(.system(size: 30))
                    .opacity(0.3)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .scaleEffect(animate1 ? 1.2 : 0.8)
                    .rotationEffect(.degrees(animate2 ? 360 : 0))
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animate1
                    )
                    .animation(
                        .linear(duration: Double.random(in: 8...12))
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.3),
                        value: animate2
                    )
            }
        }
        .onAppear {
            animate1 = true
            animate2 = true
        }
    }
}

#Preview {
    WelcomeView()
}