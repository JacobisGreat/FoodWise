//
//  SplashView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var showPulse = false
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            // Background gradient matching the login page
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.7, blue: 0.3),
                    Color(red: 0.2, green: 0.8, blue: 0.4),
                    Color(red: 0.0, green: 0.6, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo section - using the same design as LoginView
                VStack(spacing: 20) {
                    ZStack {
                        // Pulsing background circles
                        if showPulse {
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                                    .scaleEffect(showPulse ? 1.5 : 0.8)
                                    .opacity(showPulse ? 0 : 0.6)
                                    .animation(
                                        .easeInOut(duration: 2.0)
                                        .repeatForever()
                                        .delay(Double(index) * 0.3),
                                        value: showPulse
                                    )
                            }
                        }
                        
                        // Main logo circle - same as LoginView
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        // Logo icon - same as LoginView
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                    
                    // App name with enhanced animation
                    VStack(spacing: 8) {
                        Text("FoodWise")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                            .scaleEffect(animationPhase >= 2 ? 1.0 : 0.8)
                        
                        Text("Smart Nutrition Assistant")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(textOpacity)
                    }
                }
                
                Spacer()
                
                // Loading dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(.white.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .scaleEffect(showPulse ? 1.2 : 0.8)
                            .opacity(showPulse ? 1.0 : 0.6)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: showPulse
                            )
                    }
                }
                .opacity(textOpacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startSplashAnimation()
        }
    }
    
    private func startSplashAnimation() {
        // Phase 1: Logo appears (0.0 - 0.6s)
        withAnimation(.easeOut(duration: 0.6)) {
            logoScale = 1.1
            logoOpacity = 1.0
            animationPhase = 1
        }
        
        // Phase 2: Logo settles and text appears (0.3 - 0.9s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                logoScale = 1.0
                animationPhase = 2
            }
            
            withAnimation(.easeOut(duration: 0.6)) {
                textOpacity = 1.0
            }
        }
        
        // Phase 3: Start pulsing animations (0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPulse = true
        }
    }
}

#Preview {
    SplashView()
}
