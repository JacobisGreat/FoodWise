//
//  HomeView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var detectedBarcode: String?
    @State private var showingAnalysis = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello, \(authManager.currentUserProfile?.name ?? "User")!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ready to scan some food?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Main Scan Button
                VStack(spacing: 16) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            
                            Text("Scan Food")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Take a photo to analyze nutrition")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4CAF50"), Color(hex: "#45a049")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                }
                
                // Recent Scans
                if !scanHistoryManager.scanHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Scans")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink("View All", destination: HistoryView())
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#4CAF50"))
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(scanHistoryManager.scanHistory.prefix(5)) { result in
                                    RecentScanCard(result: result)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("FoodWise")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraViewScreen(
                capturedImage: $capturedImage,
                detectedBarcode: $detectedBarcode
            )
        }
        .fullScreenCover(isPresented: $showingAnalysis) {
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
            if let userId = authManager.user?.uid {
                scanHistoryManager.loadScanHistory(for: userId)
            }
        }
    }
}

struct RecentScanCard: View {
    let result: ScanResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                NutriScoreBadge(score: result.nutriScore, size: .small)
                Spacer()
            }
            
            Text(result.productName)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Text(result.scannedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 140, height: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
