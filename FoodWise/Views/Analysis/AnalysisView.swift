//
//  AnalysisView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct AnalysisDigestUpdate: Identifiable, Equatable {
    let id = UUID()
    let message: String
}

struct AnalysisRollingUpdates: View {
    let updates: [AnalysisDigestUpdate]
    let displayDuration: Double
    let rollingDuration: Double
    
    @State private var currentIndex = 0
    @State private var progressTimer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(updates[currentIndex].message)
                .font(.sectionHeader)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentIndex)
            
            // Progress indicator
            HStack(spacing: 4) {
                ForEach(0..<updates.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentIndex ? Color.primaryGreen : Color.primaryGreen.opacity(0.3))
                        .frame(width: index == currentIndex ? 24 : 8, height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                }
            }
        }
        .onAppear {
            startProgressTimer()
        }
        .onDisappear {
            progressTimer?.invalidate()
        }
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentIndex = (currentIndex + 1) % updates.count
            }
        }
    }
}

struct AnalysisView: View {
    let image: UIImage
    let barcode: String?
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var apiManager = APIManager()
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @State private var analysisResult: GeminiAnalysisResult?
    @State private var isAnalyzing = true
    @State private var errorMessage = ""
    @State private var expandedSections: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isAnalyzing {
                    // Enhanced Loading State with cooler animations
                    VStack(spacing: 60) {
                        ZStack {
                            // Background glow effect
                            Circle()
                                .fill(Color.primaryGreen.opacity(0.1))
                                .frame(width: 220, height: 220)
                                .scaleEffect(1.2)
                                .blur(radius: 10)
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 2)
                                )
                        }
                        
                        VStack(spacing: 40) {
                            AnalysisRollingUpdates(
                                updates: [
                                    AnalysisDigestUpdate(message: "🔬 Scanning nutritional content..."),
                                    AnalysisDigestUpdate(message: "📖 Reading ingredient list..."),
                                    AnalysisDigestUpdate(message: "🧠 AI analyzing health impact..."),
                                    AnalysisDigestUpdate(message: "⚕️ Checking medical compatibility..."),
                                    AnalysisDigestUpdate(message: "📊 Calculating nutrition score..."),
                                    AnalysisDigestUpdate(message: "🎯 Personalizing recommendations..."),
                                    AnalysisDigestUpdate(message: "✨ Finalizing your report...")
                                ],
                                displayDuration: 2.5,
                                rollingDuration: 0.5
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.backgroundWhite,
                                Color.primaryGreen.opacity(0.02)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                } else if !errorMessage.isEmpty {
                    // Compact Error State
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.error)
                        
                        Text("Analysis Failed")
                            .font(.sectionHeader)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                        
                        Text(errorMessage)
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button("Try Again") {
                            analyzeProduct()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundWhite)
                    
                } else if let result = analysisResult {
                    // Scrollable Results with enhanced animations
                    ScrollView {
                        LazyVStack(spacing: 24) {
                        // Product Header
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                                .cornerRadius(8)
                            
                            if let productName = result.productName {
                                Text(productName)
                                    .font(.welcomeTitle)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .contentTransition(.numericText())
                                    .animation(.bouncy(duration: 0.8), value: productName)
                            }
                            
                            VStack(spacing: 12) {
                                NutriScoreBadge(score: result.nutriScore, size: .medium)
                                
                                // Score explanation
                                VStack(spacing: 4) {
                                    Text("NutriScore \(result.nutriScore.uppercased())")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text(scoreDescription(for: result.nutriScore))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        
                        // Key Points Summary
                        VStack(spacing: 12) {
                            ExpandableSection(
                                title: "Health Impact",
                                icon: "heart.fill",
                                color: .primaryGreen,
                                isExpanded: expandedSections.contains("health"),
                                summary: "",
                                details: getHealthDetails(from: result.analysisPoints)
                            ) {
                                toggleSection("health")
                            }
                            
                            ExpandableSection(
                                title: "Key Nutrients",
                                icon: "leaf.fill",
                                color: .accentTeal,
                                isExpanded: expandedSections.contains("nutrients"),
                                summary: "",
                                details: getNutrientDetails(from: result.analysisPoints)
                            ) {
                                toggleSection("nutrients")
                            }
                            
                            ExpandableSection(
                                title: "Ingredients",
                                icon: "list.bullet",
                                color: .infoBlue,
                                isExpanded: expandedSections.contains("ingredients"),
                                summary: "",
                                details: result.ingredients ?? ["Ingredients information not available"]
                            ) {
                                toggleSection("ingredients")
                            }
                            
                            // Top Nutrients Section
                            if let topNutrients = result.topNutrients, !topNutrients.isEmpty {
                                ExpandableSection(
                                    title: "Top 3 Nutrients",
                                    icon: "star.fill",
                                    color: .primaryGreen,
                                    isExpanded: expandedSections.contains("topNutrients"),
                                    summary: "",
                                    details: topNutrients
                                ) {
                                    toggleSection("topNutrients")
                                }
                            }
                            
                            // Worst Ingredients Section
                            if let worstIngredients = result.worstIngredients, !worstIngredients.isEmpty {
                                ExpandableSection(
                                    title: "Ingredients to Watch",
                                    icon: "exclamationmark.triangle.fill",
                                    color: .warning,
                                    isExpanded: expandedSections.contains("worstIngredients"),
                                    summary: "",
                                    details: worstIngredients
                                ) {
                                    toggleSection("worstIngredients")
                                }
                            }
                            
                            // Sources/Citations Section
                            if !result.citations.isEmpty {
                                ExpandableSection(
                                    title: "Sources",
                                    icon: "doc.text.fill",
                                    color: .textSecondary,
                                    isExpanded: expandedSections.contains("sources"),
                                    summary: "",
                                    details: result.citations
                                ) {
                                    toggleSection("sources")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Auto-saved indicator
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.primaryGreen)
                                .font(.labelLarge)
                            Text("Saved to history")
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                        }
                        .padding(.top, 16)
                    }
                    .background(Color.backgroundWhite)
                }
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .onAppear {
            analyzeProduct()
        }
    }
    
    private func toggleSection(_ section: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            if expandedSections.contains(section) {
                expandedSections.remove(section)
            } else {
                expandedSections.insert(section)
            }
        }
    }
    
    private func scoreDescription(for score: String) -> String {
        switch score.uppercased() {
        case "A":
            return "Excellent nutritional quality"
        case "B":
            return "Good nutritional quality"
        case "C":
            return "Fair nutritional quality"
        case "D":
            return "Poor nutritional quality"
        case "E":
            return "Very poor nutritional quality"
        default:
            return "Nutritional quality unknown"
        }
    }

    
    private func getHealthDetails(from points: [String]) -> [String] {
        let healthKeywords = ["healthy", "unhealthy", "medical", "condition", "disease", "risk", "benefit", "avoid", "recommend", "suitable", "harmful"]
        let filtered = points.filter { point in
            healthKeywords.contains { point.lowercased().contains($0) }
        }
        // If no health-specific points found, show first half of all points
        return filtered.isEmpty ? Array(points.prefix(points.count / 2 + 1)) : filtered
    }
    
    private func getNutrientDetails(from points: [String]) -> [String] {
        let nutrientKeywords = ["protein", "sugar", "fat", "sodium", "fiber", "vitamin", "mineral", "calorie", "carb", "nutrition", "energy", "kcal"]
        let filtered = points.filter { point in
            nutrientKeywords.contains { point.lowercased().contains($0) }
        }
        // If no nutrient-specific points found, show second half of all points
        return filtered.isEmpty ? Array(points.suffix(points.count / 2)) : filtered
    }
    

    
    private func analyzeProduct() {
        guard let userProfile = authManager.currentUserProfile else { 
            print("❌ No user profile available for analysis")
            return 
        }
        
        print("🚀 Starting product analysis...")
        print("👤 User profile: \(userProfile.name), Age: \(userProfile.age), Conditions: \(userProfile.medicalConditions)")
        
        // Clear previous state to prevent flickering
        analysisResult = nil
        isAnalyzing = true
        errorMessage = ""
        
        Task {
            do {
                let result: GeminiAnalysisResult
                
                if let barcode = barcode {
                    print("📊 Analysis path: BARCODE detected - \(barcode)")
                    // Barcode detected - use Open Food Facts API
                    let productData = try await apiManager.fetchProductData(barcode: barcode)
                    result = try await apiManager.analyzeWithGemini(productData: productData, userProfile: userProfile)
                } else {
                    print("📊 Analysis path: IMAGE-ONLY (no barcode detected)")
                    // No barcode - analyze image directly
                    result = try await apiManager.analyzeImageWithGemini(image: image, userProfile: userProfile)
                }
                
                print("🎉 Analysis completed successfully!")
                print("📋 Result: NutriScore \(result.nutriScore), \(result.analysisPoints.count) points, \(result.citations.count) citations")
                
                // Automatically save the result
                await self.autoSaveResult(result)
                
                // Ensure atomic update to prevent UI flickering
                DispatchQueue.main.async {
                    // Add a small delay to ensure smooth transition
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Clear any error message first
                        self.errorMessage = ""
                        // Set both result and analyzing state atomically
                        self.analysisResult = result
                        self.isAnalyzing = false
                    }
                }
            } catch {
                print("❌ Analysis failed: \(error)")
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Clear result and set error state atomically
                        self.analysisResult = nil
                        self.isAnalyzing = false
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func autoSaveResult(_ result: GeminiAnalysisResult) async {
        guard let userId = authManager.user?.uid else {
            print("❌ Cannot auto-save: No authenticated user")
            return
        }
        
        print("💾 Auto-saving analysis result for \(result.productName ?? "Unknown Product")")
        
        let scanResult = ScanResult(
            userId: userId,
            productName: result.productName ?? "Unknown Product",
            nutriScore: result.nutriScore,
            analysisPoints: result.analysisPoints,
            citations: result.citations,
            barcode: barcode,
            ingredients: result.ingredients
        )
        
        do {
            try await scanHistoryManager.saveScanResult(scanResult)
            print("✅ Analysis automatically saved to history")
        } catch {
            print("❌ Failed to auto-save analysis: \(error)")
        }
    }
}

struct ExpandableSection: View {
    let title: String
    let icon: String
    let color: Color
    let isExpanded: Bool
    let summary: String
    let details: [String]
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main section header - always visible
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 20)
                        .scaleEffect(isExpanded ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.sectionHeader)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                        
                        if !summary.isEmpty {
                            Text(summary)
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .lineLimit(isExpanded ? nil : 2)
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isExpanded)
                }
                .padding(16)
                .background(
                    Color.cardBackground
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isExpanded ? color.opacity(0.3) : Color.clear, lineWidth: 1)
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        )
                )
                .cornerRadius(12)
                .scaleEffect(isExpanded ? 1.02 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details with smooth animation
            if isExpanded && !details.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(color)
                                .padding(.top, 6)
                            
                            Text(detail)
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .opacity(isExpanded ? 1.0 : 0.0)
                        .offset(y: isExpanded ? 0 : -10)
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.05), value: isExpanded)
                    }
                }
                .padding(16)
                .padding(.top, 8)
                .background(
                    Color.cardBackground
                        .opacity(0.7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.2), lineWidth: 1)
                        )
                )
                .cornerRadius(12)
                .padding(.top, 4)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }
}



#Preview {
    AnalysisView(image: UIImage(systemName: "photo")!, barcode: nil)
        .environmentObject(AuthManager())
}
