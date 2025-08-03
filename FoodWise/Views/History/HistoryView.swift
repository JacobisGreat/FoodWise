//
//  HistoryView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @State private var selectedResult: ScanResult?
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern animated background
                AnimatedHistoryBackground()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Header Section
                        ModernHistoryHeader()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        
                        // Content
                        if scanHistoryManager.isLoading {
                            LoadingHistorySection()
                                .padding(.horizontal, 24)
                        } else if scanHistoryManager.scanHistory.isEmpty {
                            EmptyHistorySection()
                                .padding(.horizontal, 24)
                        } else {
                            HistoryContentSection(
                                scanHistory: scanHistoryManager.scanHistory,
                                onTap: { result in selectedResult = result },
                                onDelete: deleteResults
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // Bottom padding
                        Color.clear
                            .frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            isAnimating = true
            if let userId = authManager.user?.uid {
                scanHistoryManager.loadScanHistory(for: userId)
            }
        }
        .sheet(item: $selectedResult) { result in
            ModernHistoryDetailView(result: result)
        }
    }
    
    private func deleteResults(at offsets: IndexSet) {
        for index in offsets {
            let result = scanHistoryManager.scanHistory[index]
            Task {
                try await scanHistoryManager.deleteScanResult(result)
            }
        }
    }
}

// MARK: - Modern History Components

struct AnimatedHistoryBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#F8FFFE"),
                    Color(hex: "#E8F5F3"),
                    Color(hex: "#FFFFFF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating orbs for history theme
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.accentTeal.opacity(0.08),
                                AppColors.primaryGreen.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 150...250), height: CGFloat.random(in: 150...250))
                    .blur(radius: 40)
                    .offset(
                        x: animate ? CGFloat.random(in: -120...120) : CGFloat.random(in: -60...60),
                        y: animate ? CGFloat.random(in: -250...250) : CGFloat.random(in: -125...125)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 10...15))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 2.5),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

struct ModernHistoryHeader: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan History")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: isAnimating)
                    
                    Text("Your nutrition journey")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(AppColors.accentTeal.opacity(0.15))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: isAnimating)
                    
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.accentTeal)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingHistorySection: View {
    @State private var loadingRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(AppColors.primaryGreen.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(AppColors.primaryGreen, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(loadingRotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: loadingRotation)
            }
            
            Text("Loading your scan history...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .onAppear {
            loadingRotation = 360
        }
    }
}

struct EmptyHistorySection: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                CustomIcons.HistoryIcon(size: 60, isActive: false)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isAnimating)
            }
            
            VStack(spacing: 16) {
                Text("No Scan History Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                Text("Start scanning foods to build your\nnutrition history and track your journey")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: isAnimating)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .onAppear {
            isAnimating = true
        }
    }
}

struct HistoryContentSection: View {
    let scanHistory: [ScanResult]
    let onTap: (ScanResult) -> Void
    let onDelete: (IndexSet) -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Stats overview
            HistoryStatsCard(scanHistory: scanHistory)
            
            // History list
            VStack(spacing: 16) {
                HStack {
                    Text("Recent Scans")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(scanHistory.count) scans")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(Array(scanHistory.enumerated()), id: \.element.id) { index, result in
                        ModernHistoryRow(
                            result: result,
                            delay: Double(index) * 0.1
                        )
                        .onTapGesture {
                            onTap(result)
                        }
                    }
                }
            }
        }
    }
}

struct HistoryStatsCard: View {
    let scanHistory: [ScanResult]
    @State private var isAnimating = false
    
    var totalScans: Int { scanHistory.count }
    var averageScore: String {
        let scores = scanHistory.compactMap { $0.nutriScore.nutriScoreValue }
        guard !scores.isEmpty else { return "N/A" }
        
        let average = Double(scores.reduce(0, +)) / Double(scores.count)
        switch average {
        case 4.5...5.0: return "A"
        case 3.5..<4.5: return "B+"
        case 2.5..<3.5: return "C"
        case 1.5..<2.5: return "D"
        default: return "E"
        }
    }
    var recentActivity: String {
        let recent = scanHistory.filter { 
            Calendar.current.isDate($0.scannedAt, inSameDayAs: Date()) 
        }.count
        return "\(recent) today"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                HistoryStatItem(
                    icon: "chart.bar.fill",
                    title: "Total Scans",
                    value: "\(totalScans)",
                    color: AppColors.primaryGreen,
                    delay: 0.1
                )
                
                HistoryStatItem(
                    icon: "star.fill",
                    title: "Avg Score",
                    value: averageScore,
                    color: AppColors.accentTeal,
                    delay: 0.2
                )
                
                HistoryStatItem(
                    icon: "calendar",
                    title: "Today",
                    value: recentActivity,
                    color: AppColors.infoBlue,
                    delay: 0.3
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct HistoryStatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernHistoryRow: View {
    let result: ScanResult
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // NutriScore badge
            ZStack {
                Circle()
                    .fill(result.nutriScore.nutriScoreColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                NutriScoreBadge(score: result.nutriScore, size: .medium)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(result.productName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                
                Text(result.scannedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                if !result.analysisPoints.isEmpty {
                    Text(result.analysisPoints.first ?? "")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Helper Extensions

extension String {
    var nutriScoreValue: Int {
        switch self.uppercased() {
        case "A": return 5
        case "B": return 4
        case "C": return 3
        case "D": return 2
        case "E": return 1
        default: return 0
        }
    }
    
    var nutriScoreColor: Color {
        switch self.uppercased() {
        case "A": return AppColors.primaryGreen
        case "B": return AppColors.accentTeal
        case "C": return AppColors.warning
        case "D": return AppColors.error
        case "E": return AppColors.error
        default: return AppColors.textSecondary
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AuthManager())
}

struct ModernHistoryDetailView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#F8FFFE"),
                        Color(hex: "#FFFFFF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header with product info
                        ModernDetailHeader(result: result)
                        
                        // Analysis section
                        if !result.analysisPoints.isEmpty {
                            ModernAnalysisSection(analysisPoints: result.analysisPoints)
                        }
                        
                        // Citations section
                        if !result.citations.isEmpty {
                            ModernCitationsSection(citations: result.citations)
                        }
                        
                        // Scan info section
                        ModernScanInfoSection(result: result)
                        
                        // Bottom padding
                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernDetailHeader: View {
    let result: ScanResult
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Product name
            Text(result.productName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(0.2), value: isAnimating)
            
            // NutriScore section
            VStack(spacing: 16) {
                Text("Nutrition Score")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                ZStack {
                    Circle()
                        .fill(result.nutriScore.nutriScoreColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: isAnimating)
                    
                    NutriScoreBadge(score: result.nutriScore, size: .large)
                        .scaleEffect(isAnimating ? 1.0 : 0.6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: isAnimating)
                }
            }
        }
        .padding(.top, 20)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernAnalysisSection: View {
    let analysisPoints: [String]
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryGreen.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                    
                    Text("Health Analysis")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(Array(analysisPoints.enumerated()), id: \.offset) { index, point in
                    ModernAnalysisPoint(
                        point: point,
                        delay: Double(index) * 0.1
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernAnalysisPoint: View {
    let point: String
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .padding(.top, 8)
                
                Circle()
                    .fill(AppColors.primaryGreen)
                    .frame(width: 6, height: 6)
                    .padding(.top, 8)
            }
            
            Text(point)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(x: isAnimating ? 0 : 20)
        .animation(.easeInOut(duration: 0.6).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernCitationsSection: View {
    let citations: [String]
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.infoBlue.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.infoBlue)
                    }
                    
                    Text("Sources")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(citations.enumerated()), id: \.offset) { index, citation in
                    HStack(alignment: .top, spacing: 12) {
                        Text("•")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.infoBlue)
                            .padding(.top, 2)
                        
                        Text(citation)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(x: isAnimating ? 0 : 20)
                    .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1), value: isAnimating)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.5), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernScanInfoSection: View {
    let result: ScanResult
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentTeal.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.accentTeal)
                    }
                    
                    Text("Scan Details")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                HStack {
                    Text("Scanned on")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text(result.scannedAt.formatted(date: .complete, time: .shortened))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Divider()
                    .background(AppColors.surfaceSecondary)
                
                HStack {
                    Text("Product ID")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text((result.id ?? "Unknown").prefix(8).uppercased())
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.7), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AuthManager())
}
