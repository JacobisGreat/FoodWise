//
//  ScanHistoryManager.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseFirestore
import Combine

class ScanHistoryManager: ObservableObject {
    @Published var scanHistory: [ScanResult] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func loadScanHistory(for userId: String) {
        print("📚 Loading scan history for userId: \(userId)")
        isLoading = true
        
        // Simplified query to avoid index requirement
        db.collection("scanResults")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    print("❌ Error loading scan history: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { 
                    print("⚠️ No documents found in scan history query")
                    return 
                }
                
                print("📊 Found \(documents.count) scan history documents")
                
                let results = documents.compactMap { document -> ScanResult? in
                    let data = document.data()
                    
                    // Handle the scannedAt timestamp properly
                    let scannedAt: Date
                    if let timestamp = data["scannedAt"] as? Timestamp {
                        scannedAt = timestamp.dateValue()
                    } else if let date = data["scannedAt"] as? Date {
                        scannedAt = date
                    } else {
                        scannedAt = Date() // Fallback to current date
                    }
                    
                    let result = ScanResult(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        productName: data["productName"] as? String ?? "",
                        productImage: data["productImage"] as? String,
                        nutriScore: data["nutriScore"] as? String ?? "",
                        analysisPoints: data["analysisPoints"] as? [String] ?? [],
                        citations: data["citations"] as? [String] ?? [],
                        barcode: data["barcode"] as? String,
                        scannedAt: scannedAt
                    )
                    
                    print("📱 Loaded scan result: \(result.productName) - \(result.nutriScore) - \(result.scannedAt)")
                    
                    return result
                }
                
                // Sort by date in memory instead of in query
                let sortedResults = results.sorted { $0.scannedAt > $1.scannedAt }
                
                print("✅ Loaded \(sortedResults.count) scan results, sorted by date")
                
                DispatchQueue.main.async {
                    self?.scanHistory = sortedResults
                }
            }
    }
    
    func saveScanResult(_ result: ScanResult) async throws {
        print("💾 Saving scan result: \(result.productName) for user: \(result.userId)")
        
        let data: [String: Any] = [
            "userId": result.userId,
            "productName": result.productName,
            "productImage": result.productImage as Any,
            "nutriScore": result.nutriScore,
            "analysisPoints": result.analysisPoints,
            "citations": result.citations,
            "scannedAt": result.scannedAt,
            "barcode": result.barcode as Any
        ]
        
        print("📦 Scan result data: \(data)")
        
        let docRef = try await db.collection("scanResults").addDocument(data: data)
        print("✅ Scan result saved with ID: \(docRef.documentID)")
        
        // Add to local array immediately for better UX
        DispatchQueue.main.async {
            var resultWithId = result
            resultWithId.id = docRef.documentID
            self.scanHistory.insert(resultWithId, at: 0)
            print("📱 Added to local scan history. Total items: \(self.scanHistory.count)")
        }
    }
    
    func deleteScanResult(_ result: ScanResult) async throws {
        guard let documentId = result.id else { return }
        
        try await db.collection("scanResults").document(documentId).delete()
        
        DispatchQueue.main.async {
            self.scanHistory.removeAll { $0.id == result.id }
        }
    }
}
