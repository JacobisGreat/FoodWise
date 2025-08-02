//
//  CustomIcons.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct CustomIcons {
    
    // MARK: - Scan Icons
    struct ScanBarcodeIcon: View {
        let size: CGFloat
        
        init(size: CGFloat = 24) {
            self.size = size
        }
        
        var body: some View {
            ZStack {
                // Barcode lines
                HStack(spacing: size * 0.05) {
                    ForEach(0..<8) { index in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: size * (index % 3 == 0 ? 0.08 : 0.04), height: size * 0.6)
                    }
                }
                
                // Scanner overlay
                RoundedRectangle(cornerRadius: size * 0.1)
                    .stroke(Color.white.opacity(0.8), lineWidth: size * 0.06)
                    .frame(width: size * 0.9, height: size * 0.8)
                
                // Corner brackets
                VStack {
                    HStack {
                        CornerBracket(size: size * 0.15)
                        Spacer()
                        CornerBracket(size: size * 0.15)
                            .rotationEffect(.degrees(90))
                    }
                    Spacer()
                    HStack {
                        CornerBracket(size: size * 0.15)
                            .rotationEffect(.degrees(270))
                        Spacer()
                        CornerBracket(size: size * 0.15)
                            .rotationEffect(.degrees(180))
                    }
                }
                .frame(width: size, height: size * 0.8)
            }
        }
    }
    
    struct ScanLabelIcon: View {
        let size: CGFloat
        
        init(size: CGFloat = 24) {
            self.size = size
        }
        
        var body: some View {
            ZStack {
                // Document background
                RoundedRectangle(cornerRadius: size * 0.1)
                    .fill(Color.white)
                    .frame(width: size * 0.8, height: size)
                
                // Text lines representing nutrition label
                VStack(spacing: size * 0.05) {
                    Rectangle()
                        .fill(Color.primaryGreen)
                        .frame(width: size * 0.6, height: size * 0.06)
                    
                    Rectangle()
                        .fill(Color.textSecondary)
                        .frame(width: size * 0.5, height: size * 0.04)
                    
                    Rectangle()
                        .fill(Color.textSecondary)
                        .frame(width: size * 0.4, height: size * 0.04)
                    
                    Rectangle()
                        .fill(Color.textSecondary)
                        .frame(width: size * 0.55, height: size * 0.04)
                }
                
                // Scanner effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.primaryGreenLight.opacity(0.6), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size * 0.02, height: size)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: true)
            }
        }
    }
    
    // MARK: - Navigation Icons
    struct HomeIcon: View {
        let size: CGFloat
        let isActive: Bool
        
        init(size: CGFloat = 24, isActive: Bool = false) {
            self.size = size
            self.isActive = isActive
        }
        
        var body: some View {
            ZStack {
                // Modern house shape
                Path { path in
                    // Roof
                    path.move(to: CGPoint(x: size * 0.5, y: size * 0.15))
                    path.addLine(to: CGPoint(x: size * 0.15, y: size * 0.45))
                    path.addLine(to: CGPoint(x: size * 0.85, y: size * 0.45))
                    path.closeSubpath()
                    
                    // House body
                    path.addRect(CGRect(x: size * 0.2, y: size * 0.4, width: size * 0.6, height: size * 0.45))
                }
                .fill(isActive ? Color.primaryGreen : Color.labelGray)
                
                // Door
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(isActive ? Color.backgroundWhite : Color.panelOffWhite)
                    .frame(width: size * 0.12, height: size * 0.2)
                    .offset(x: size * 0.1, y: size * 0.125)
                
                // Window
                RoundedRectangle(cornerRadius: size * 0.015)
                    .fill(isActive ? Color.backgroundWhite : Color.panelOffWhite)
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(x: -size * 0.1, y: size * 0.05)
            }
        }
    }
    
    struct HistoryIcon: View {
        let size: CGFloat
        let isActive: Bool
        
        init(size: CGFloat = 24, isActive: Bool = false) {
            self.size = size
            self.isActive = isActive
        }
        
        var body: some View {
            ZStack {
                // Document stack
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: size * 0.08)
                        .fill(isActive ? Color.primaryGreenLight.opacity(0.8 - Double(index) * 0.2) : Color.textTertiary.opacity(0.8 - Double(index) * 0.2))
                        .frame(width: size * 0.65, height: size * 0.75)
                        .offset(x: CGFloat(index) * size * 0.04, y: -CGFloat(index) * size * 0.04)
                }
                
                // Clock overlay on top document
                Circle()
                    .fill(isActive ? Color.accentTeal : Color.labelGray)
                    .frame(width: size * 0.35, height: size * 0.35)
                    .overlay(
                        // Clock hands
                        ZStack {
                            Path { path in
                                path.move(to: CGPoint(x: size * 0.175, y: size * 0.175))
                                path.addLine(to: CGPoint(x: size * 0.175, y: size * 0.1))
                            }
                            .stroke(Color.white, lineWidth: size * 0.02)
                            
                            Path { path in
                                path.move(to: CGPoint(x: size * 0.175, y: size * 0.175))
                                path.addLine(to: CGPoint(x: size * 0.22, y: size * 0.175))
                            }
                            .stroke(Color.white, lineWidth: size * 0.015)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.03, height: size * 0.03)
                        }
                    )
                    .offset(x: size * 0.06, y: -size * 0.06)
            }
        }
    }
    
    struct ProfileIcon: View {
        let size: CGFloat
        let isActive: Bool
        
        init(size: CGFloat = 24, isActive: Bool = false) {
            self.size = size
            self.isActive = isActive
        }
        
        var body: some View {
            ZStack {
                // Person silhouette
                VStack(spacing: 0) {
                    // Head
                    Circle()
                        .fill(isActive ? Color.primaryGreen : Color.textTertiary)
                        .frame(width: size * 0.3, height: size * 0.3)
                    
                    // Body (trapezoid shape)
                    Path { path in
                        path.move(to: CGPoint(x: size * 0.3, y: 0))
                        path.addLine(to: CGPoint(x: size * 0.7, y: 0))
                        path.addLine(to: CGPoint(x: size * 0.85, y: size * 0.4))
                        path.addLine(to: CGPoint(x: size * 0.15, y: size * 0.4))
                        path.closeSubpath()
                    }
                                            .fill(isActive ? Color.primaryGreen : Color.textTertiary)
                    .frame(width: size, height: size * 0.4)
                }
                .frame(width: size * 0.65, height: size * 0.7)
                
                // Background circle
                Circle()
                    .stroke(isActive ? Color.primaryGreen.opacity(0.3) : Color.labelGray.opacity(0.3), lineWidth: size * 0.04)
                    .frame(width: size * 0.9, height: size * 0.9)
            }
        }
    }
    
    // MARK: - Helper Views
    struct CornerBracket: View {
        let size: CGFloat
        
        var body: some View {
            Path { path in
                path.move(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
            }
            .stroke(Color.white, lineWidth: size * 0.2)
        }
    }
}

// MARK: - Loading Animation Components
struct LoadingDots: View {
    @State private var animating = false
    let color: Color
    let size: CGFloat
    
    init(color: Color = .primaryGreen, size: CGFloat = 8) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: size * 0.5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .scaleEffect(animating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct PulsingCircle: View {
    @State private var pulsing = false
    let color: Color
    let size: CGFloat
    
    init(color: Color = .primaryGreenLight, size: CGFloat = 100) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(pulsing ? 1.5 : 0.5)
                    .opacity(pulsing ? 0 : 1)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever()
                        .delay(Double(index) * 0.3),
                        value: pulsing
                    )
            }
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.8), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
        }
        .onAppear {
            pulsing = true
        }
    }
}
