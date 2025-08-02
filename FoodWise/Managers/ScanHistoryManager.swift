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
        isLoading = true
        
        // Simplified query to avoid index requirement
        db.collection("scanResults")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    print("Error loading scan history: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                let results = documents.compactMap { document -> ScanResult? in
                    let data = document.data()
                    
                    return ScanResult(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        productName: data["productName"] as? String ?? "",
                        productImage: data["productImage"] as? String,
                        nutriScore: data["nutriScore"] as? String ?? "",
                        analysisPoints: data["analysisPoints"] as? [String] ?? [],
                        citations: data["citations"] as? [String] ?? [],
                        barcode: data["barcode"] as? String
                    )
                }
                
                // Sort by date in memory instead of in query
                let sortedResults = results.sorted { ($0.scannedAt) > ($1.scannedAt) }
                
                DispatchQueue.main.async {
                    self?.scanHistory = sortedResults
                }
            }
    }
    
    func saveScanResult(_ result: ScanResult) async throws {
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
        
        let docRef = try await db.collection("scanResults").addDocument(data: data)
        
        // Add to local array immediately for better UX
        DispatchQueue.main.async {
            var resultWithId = result
            resultWithId.id = docRef.documentID
            self.scanHistory.insert(resultWithId, at: 0)
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
