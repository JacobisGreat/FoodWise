//
//  HomeView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var scanHistoryManager: ScanHistoryManager
    @EnvironmentObject var tabNavigationManager: TabNavigationManager
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var detectedBarcode: String?
    @State private var showingAnalysis = false
    @State private var showingChat = false
    @State private var isAnimating = false
    @State private var currentTipIndex = 0
    
    // Enhanced nutrition tips with emojis
    private let nutritionTips = [
        "🍯 Look for foods with less than 5g of added sugar per serving",
        "🌾 Choose products with more fiber - aim for at least 3g per serving",
        "🚫 Avoid items with trans fats or partially hydrogenated oils",
        "🧂 Sodium should be less than 140mg per serving for 'low sodium' foods",
        "📝 Check ingredient lists - shorter is often better",
        "🌾 Whole grains should be listed as the first ingredient",
        "⚖️ Be mindful of serving sizes - they're often smaller than you think!",
        "📊 Foods with 15% or more Daily Value are considered high sources"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background with animated gradients
                AnimatedBackground()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 32) {
                        // Modern Header with animated greeting
                        ModernHeader()
                            .environmentObject(authManager)
                            .environmentObject(tabNavigationManager)
                        
                        // Scan Nutritional Facts Card
                        ScanCard(showingCamera: $showingCamera)
                        
                        // AI Chat Card
                        AIChatCard(showingChat: $showingChat)
                        
                        // Daily Insights Dashboard
                        InsightsDashboard()
                            .environmentObject(scanHistoryManager)
                        
                        // Rotating Nutrition Tips
                        NutritionTipCard(tips: nutritionTips, currentIndex: $currentTipIndex)
                        
                        // Recent Scans with enhanced visuals
                        RecentScansSection()
                            .environmentObject(scanHistoryManager)
                            .environmentObject(tabNavigationManager)
                        
                        // Achievement Badges
                        AchievementSection()
                        
                        // Extra spacing for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAnimating = true
                startTipRotation()
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
                .environmentObject(authManager)
                .environmentObject(scanHistoryManager)
        }
        .sheet(isPresented: $showingCamera) {
            CameraViewScreen(
                capturedImage: $capturedImage,
                detectedBarcode: $detectedBarcode
            )
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { showingAnalysis && capturedImage != nil },
                set: { if !$0 { showingAnalysis = false; capturedImage = nil; detectedBarcode = nil } }
            )
        ) {
            if let image = capturedImage {
                AnalysisView(image: image, barcode: detectedBarcode)
                    .environmentObject(authManager)
            }
        }
        .onChange(of: capturedImage) { oldValue, newValue in
            if newValue != nil {
                showingAnalysis = true
            }
        }
    }
    

    
    private func startTipRotation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTipIndex = (currentTipIndex + 1) % nutritionTips.count
            }
        }
    }
}

struct AnimatedBackground: View {
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
            
            // Floating orbs
            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.primaryGreen.opacity(0.1),
                                AppColors.accentTeal.opacity(0.05)
                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .offset(
                        x: animate ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                        y: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 2),
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

struct ModernHeader: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tabNavigationManager: TabNavigationManager
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hello")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(authManager.currentUserProfile?.name ?? "User")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
                }
                
                Text("Ready to discover what's in your food?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: isAnimating)
                                    }
                                    
                                    Spacer()
                                    
            // Modern avatar with pulse effect
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(
                                    LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.primaryGreen,
                                AppColors.accentTeal
                            ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(authManager.currentUserProfile?.name.prefix(1) ?? "U"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
                    .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    tabNavigationManager.selectedTab = 2
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ScanCard: View {
    @Binding var showingCamera: Bool
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showingCamera = true }) {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 80, height: 80)
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isAnimating)
                    
                    VStack(spacing: 8) {
                        Text("Scan QR & Nutritional Facts")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Quickly analyze product labels and barcodes")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: isAnimating)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
            .onAppear {
                isAnimating = true
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AIChatCard: View {
    @Binding var showingChat: Bool
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showingChat = true }) {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.infoBlue)
                            .frame(width: 80, height: 80)
                            .shadow(color: AppColors.infoBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isAnimating)
                    
                    VStack(spacing: 8) {
                        Text("AI Nutrition Chat")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Ask questions about food and nutrition")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: isAnimating)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
            .onAppear {
                isAnimating = true
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InsightsDashboard: View {
    @EnvironmentObject var scanHistoryManager: ScanHistoryManager
    
    private var averageNutriScore: String {
        let scores = scanHistoryManager.scanHistory.compactMap { scan -> Int? in
            switch scan.nutriScore.uppercased() {
            case "A": return 5
            case "B": return 4
            case "C": return 3
            case "D": return 2
            case "E": return 1
            default: return nil
            }
        }
        
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
    
    private var scanStreak: Int {
        // Calculate consecutive days with scans
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        
        let sortedScans = scanHistoryManager.scanHistory.sorted { $0.scannedAt > $1.scannedAt }
        var currentDate = today
        
        for scan in sortedScans {
            if calendar.isDate(scan.scannedAt, inSameDayAs: currentDate) {
                if calendar.isDate(currentDate, inSameDayAs: today) {
                    streak += 1
                }
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Insights")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                InsightCard(
                    icon: "chart.bar.fill",
                    title: "Scans",
                                            value: "\(scanHistoryManager.scanHistory.count)",
                    subtitle: "This week",
                    color: AppColors.primaryGreen,
                    delay: 0.1
                )
                
                InsightCard(
                    icon: "star.fill",
                    title: "Avg Score",
                    value: averageNutriScore,
                    subtitle: "Keep it up!",
                    color: AppColors.accentTeal,
                    delay: 0.2
                )
                
                InsightCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(scanStreak)",
                    subtitle: "Days",
                    color: AppColors.warning,
                    delay: 0.3
                )
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct NutritionTipCard: View {
    let tips: [String]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💡 Daily Tip")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(currentIndex + 1)/\(tips.count)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.textTertiary.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Text(tips[currentIndex])
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .contentTransition(.numericText())
                .animation(.bouncy(duration: 0.5), value: currentIndex)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.infoBlue.opacity(0.1),
                            AppColors.accentTeal.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct RecentScansSection: View {
    @EnvironmentObject var scanHistoryManager: ScanHistoryManager
    @EnvironmentObject var tabNavigationManager: TabNavigationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Scans")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    tabNavigationManager.selectedTab = 1
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.primaryGreen)
            }
            
            if scanHistoryManager.scanHistory.isEmpty {
                EmptyScansView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(scanHistoryManager.scanHistory.prefix(5)) { scan in
                            ModernScanCard(scan: scan)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct ModernScanCard: View {
    let scan: ScanResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                NutriScoreBadge(score: scan.nutriScore, size: .small)
                Spacer()
                Text(scan.scannedAt.timeAgoDisplay())
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
            }
            
            Text(scan.productName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
            if let firstPoint = scan.analysisPoints.first {
                Text(firstPoint)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(width: 160, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
}

struct EmptyScansView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No scans yet")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Start by scanning your first product!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.textTertiary.opacity(0.05))
        .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.textTertiary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        )
    }
}

struct AchievementSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                AchievementBadge(
                    icon: "🏆",
                    title: "First Scan",
                    isUnlocked: true
                )
                
                AchievementBadge(
                    icon: "🔥",
                    title: "7 Day Streak",
                    isUnlocked: false
                )
                
                AchievementBadge(
                    icon: "📊",
                    title: "Health Expert",
                    isUnlocked: false
                )
            }
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppColors.primaryGreen.opacity(0.2) : AppColors.textTertiary.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(icon)
                    .font(.system(size: 24))
                    .grayscale(isUnlocked ? 0 : 1)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(isUnlocked ? AppColors.textPrimary : AppColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// Extension for time ago display
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}