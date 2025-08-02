//
//  HomeView.swift
//  FoodWise
//
//  Created by doomi the goat  on 2025-08-02.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var detectedBarcode: String?
    @State private var showingAnalysis = false
    
    // Daily nutrition tips
    private let nutritionTips = [
        "Look for foods with less than 5g of added sugar per serving.",
        "Choose products with more fiber - aim for at least 3g per serving.",
        "Avoid items with trans fats or partially hydrogenated oils.",
        "Sodium should be less than 140mg per serving for 'low sodium' foods.",
        "Check ingredient lists - shorter is often better.",
        "Whole grains should be listed as the first ingredient in grain products.",
        "Be mindful of serving sizes - they're often smaller than you think!",
        "Foods with 15% or more Daily Value of a nutrient are considered high sources."
    ]
    
    private var dailyTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return nutritionTips[dayOfYear % nutritionTips.count]
    }
    
    private var scansThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return scanHistoryManager.scanHistory.filter { $0.scannedAt >= weekAgo }.count
    }
    
    private var averageNutriScore: String {
        guard !scanHistoryManager.scanHistory.isEmpty else { return "-" }
        
        let scores = scanHistoryManager.scanHistory.compactMap { result -> Double? in
            switch result.nutriScore.uppercased() {
            case "A": return 5.0
            case "B": return 4.0
            case "C": return 3.0
            case "D": return 2.0
            case "E": return 1.0
            default: return nil
            }
        }
        
        guard !scores.isEmpty else { return "-" }
        let average = scores.reduce(0, +) / Double(scores.count)
        
        switch average {
        case 4.5...5.0: return "A"
        case 3.5..<4.5: return "B"
        case 2.5..<3.5: return "C"
        case 1.5..<2.5: return "D"
        default: return "E"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.backgroundWhite, Color.panelOffWhite],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hello, \(authManager.currentUserProfile?.name ?? "User")!")
                                        .font(.welcomeTitle)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("Ready to scan some food?")
                                        .font(.bodyLarge)
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                
                                // Profile avatar
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.primaryGreenLight, Color.primaryGreen],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(String(authManager.currentUserProfile?.name.prefix(1) ?? "U"))
                                            .font(.labelLarge)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    )
                                    .softShadow()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // Scan Buttons
                        VStack(spacing: 16) {
                            // Barcode Scan Button
                            Button(action: {
                                showingCamera = true
                            }) {
                                HStack(spacing: 16) {
                                    CustomIcons.ScanBarcodeIcon(size: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Scan Barcode")
                                            .font(.sectionHeader)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        Text("Quick product lookup")
                                            .font(.bodyMedium)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.primaryGreen.opacity(0.9), Color.primaryGreen],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .buttonShadow()
                            }
                            
                            // Label Scan Button
                            Button(action: {
                                showingCamera = true
                            }) {
                                HStack(spacing: 16) {
                                    CustomIcons.ScanLabelIcon(size: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Scan Nutrition Label")
                                            .font(.sectionHeader)
                                            .fontWeight(.medium)
                                            .foregroundColor(.textPrimary)
                                        
                                        Text("Detailed nutrition analysis")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primaryGreen.opacity(0.7))
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(Color.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 1.5)
                                )
                                .cornerRadius(20)
                                .cardShadow()
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Recent Scans Section
                        if scanHistoryManager.isLoading {
                            FoodWiseCard {
                                VStack(spacing: 16) {
                                    LoadingDotsView(color: .primaryGreen, size: 10)
                                    Text("Loading scan history...")
                                        .font(.bodyMedium)
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(height: 80)
                            }
                            .padding(.horizontal, 24)
                        } else if !scanHistoryManager.scanHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Recent Scans")
                                        .font(.sectionHeader)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink("View All", destination: HistoryView())
                                        .font(.labelMedium)
                                        .foregroundColor(.primaryGreen)
                                }
                                .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(scanHistoryManager.scanHistory.prefix(5)) { result in
                                            RecentScanCard(result: result)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        } else {
                            FoodWiseCard {
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.badge.plus")
                                        .font(.system(size: 32))
                                        .foregroundColor(.primaryGreen.opacity(0.6))
                                    
                                    Text("No scan history yet")
                                        .font(.sectionHeader)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("Start scanning to see your history here!")
                                        .font(.bodyLarge)
                                        .foregroundColor(.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 120)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Daily Nutrition Tip
                        FoodWiseCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.infoBlue)
                                    
                                    Text("Today's Tip")
                                        .font(.sectionHeader)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                }
                                
                                Text(dailyTip)
                                    .font(.bodyLarge)
                                    .foregroundColor(.textSecondary)
                                    .lineLimit(3)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Quick Stats (if user has scan history)
                        if !scanHistoryManager.scanHistory.isEmpty {
                            FoodWiseCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.accentTeal)
                                        
                                        Text("Your Stats")
                                            .font(.sectionHeader)
                                            .fontWeight(.medium)
                                            .foregroundColor(.textPrimary)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 24) {
                                        StatItem(
                                            title: "Total Scans",
                                            value: "\(scanHistoryManager.scanHistory.count)",
                                            icon: "doc.text.magnifyingglass",
                                            color: .primaryGreen
                                        )
                                        
                                        StatItem(
                                            title: "This Week",
                                            value: "\(scansThisWeek)",
                                            icon: "calendar",
                                            color: .accentTeal
                                        )
                                        
                                        StatItem(
                                            title: "Avg Score",
                                            value: averageNutriScore,
                                            icon: "star.fill",
                                            color: .infoBlue
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraViewScreen(
                capturedImage: $capturedImage,
                detectedBarcode: $detectedBarcode
            )
        }
        .fullScreenCover(isPresented: $showingAnalysis, onDismiss: {
            // Refresh scan history when returning from analysis
            if let userId = authManager.user?.uid {
                scanHistoryManager.loadScanHistory(for: userId)
            }
        }) {
            if let image = capturedImage {
                AnalysisView(
                    image: image,
                    barcode: detectedBarcode
                )
            }
        }
        .onChange(of: capturedImage) { image in
            if image != nil {
                showingAnalysis = true
            }
        }
        .onAppear {
            print("🏠 HomeView appeared")
            if let userId = authManager.user?.uid {
                print("👤 Loading scan history for user: \(userId)")
                scanHistoryManager.loadScanHistory(for: userId)
            } else {
                print("⚠️ No authenticated user found")
            }
        }
    }
}

struct RecentScanCard: View {
    let result: ScanResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                NutriScoreBadge(score: result.nutriScore, size: .small)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textTertiary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(result.productName)
                    .font(.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(result.scannedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(width: 160, height: 120)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .cardShadow()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryGreen.opacity(0.1), lineWidth: 1)
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.sectionHeader)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}



#Preview {
    HomeView()
        .environmentObject(AuthManager())
}

// doomi was here 