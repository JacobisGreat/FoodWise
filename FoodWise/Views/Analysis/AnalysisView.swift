//
//  AnalysisView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct AnalysisView: View {
    let image: UIImage
    let barcode: String?
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var apiManager = APIManager()
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @State private var analysisResult: GeminiAnalysisResult?
    @State private var isAnalyzing = true
    @State private var errorMessage = ""
    @State private var showingSaveConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Product Image
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    if isAnalyzing {
                        // Loading State
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Analyzing nutrition...")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            if let barcode = barcode {
                                Text("Found barcode: \(barcode)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Fetching product data...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("No barcode detected")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("Reading nutrition label...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    } else if !errorMessage.isEmpty {
                        // Error State
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("Analysis Failed")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Try Again") {
                                analyzeProduct()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if let result = analysisResult {
                        // Results State
                        VStack(spacing: 24) {
                            // Product Name
                            if let productName = result.productName {
                                Text(productName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // NutriScore
                            VStack(spacing: 8) {
                                Text("NutriScore")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                NutriScoreBadge(score: result.nutriScore, size: .large)
                            }
                            
                            // Analysis Points
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Health Analysis")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                ForEach(result.analysisPoints, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .foregroundColor(Color(hex: "#4CAF50"))
                                            .padding(.top, 6)
                                        
                                        Text(point)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            
                            // Citations
                            if !result.citations.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Sources")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    ForEach(result.citations, id: \.self) { citation in
                                        Text("• \(citation)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                            }
                            
                            // Save Button
                            Button(action: saveResult) {
                                Text("Save to History")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(hex: "#4CAF50"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            analyzeProduct()
        }
        .alert("Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Analysis saved to your history")
        }
    }
    
    private func analyzeProduct() {
        guard let userProfile = authManager.currentUserProfile else { 
            print("❌ No user profile available for analysis")
            return 
        }
        
        print("🚀 Starting product analysis...")
        print("👤 User profile: \(userProfile.name), Age: \(userProfile.age), Conditions: \(userProfile.medicalConditions)")
        
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
                
                DispatchQueue.main.async {
                    self.analysisResult = result
                    self.isAnalyzing = false
                }
            } catch {
                print("❌ Analysis failed: \(error)")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func saveResult() {
        guard let result = analysisResult,
              let userId = authManager.user?.uid else { return }
        
        let scanResult = ScanResult(
            userId: userId,
            productName: result.productName ?? "Unknown Product",
            nutriScore: result.nutriScore,
            analysisPoints: result.analysisPoints,
            citations: result.citations,
            barcode: barcode
        )
        
        Task {
            do {
                try await scanHistoryManager.saveScanResult(scanResult)
                DispatchQueue.main.async {
                    self.showingSaveConfirmation = true
                }
            } catch {
                print("Error saving result: \(error)")
            }
        }
    }
}

#Preview {
    AnalysisView(image: UIImage(systemName: "photo")!, barcode: nil)
        .environmentObject(AuthManager())
}
