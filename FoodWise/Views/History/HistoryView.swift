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
    
    var body: some View {
        NavigationView {
            VStack {
                if scanHistoryManager.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading history...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if scanHistoryManager.scanHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Scan History")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start scanning food to see your history here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(scanHistoryManager.scanHistory) { result in
                            HistoryRow(result: result)
                                .onTapGesture {
                                    selectedResult = result
                                }
                        }
                        .onDelete(perform: deleteResults)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if let userId = authManager.user?.uid {
                scanHistoryManager.loadScanHistory(for: userId)
            }
        }
        .sheet(item: $selectedResult) { result in
            HistoryDetailView(result: result)
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

struct HistoryRow: View {
    let result: ScanResult
    
    var body: some View {
        HStack(spacing: 12) {
            NutriScoreBadge(score: result.nutriScore, size: .medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(result.scannedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !result.analysisPoints.isEmpty {
                    Text(result.analysisPoints.first ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct HistoryDetailView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Product Name and Score
                    VStack(spacing: 16) {
                        Text(result.productName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 8) {
                            Text("NutriScore")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            NutriScoreBadge(score: result.nutriScore, size: .large)
                        }
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
                    
                    // Scan Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scanned")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(result.scannedAt.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Scan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AuthManager())
}
