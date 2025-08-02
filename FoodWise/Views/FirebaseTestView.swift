//
//  FirebaseTestView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseTestView: View {
    @State private var testResult = "Testing..."
    @State private var userData: [String: Any] = [:]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Firebase Connection Test")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(testResult)
                .foregroundColor(testResult.contains("✅") ? .green : .red)
            
            if !userData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Data from Firestore:")
                        .fontWeight(.semibold)
                    
                    ForEach(userData.keys.sorted(), id: \.self) { key in
                        Text("\(key): \(String(describing: userData[key] ?? "nil"))")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Test Firebase") {
                testFirebase()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            testFirebase()
        }
    }
    
    private func testFirebase() {
        testResult = "Testing Firebase connection..."
        
        let db = Firestore.firestore()
        
        // Test writing data
        let testData: [String: Any] = [
            "test": true,
            "timestamp": Date(),
            "message": "Firebase is working!"
        ]
        
        db.collection("test").document("connection").setData(testData) { error in
            if let error = error {
                testResult = "❌ Firebase write failed: \(error.localizedDescription)"
            } else {
                // Test reading data
                db.collection("test").document("connection").getDocument { snapshot, error in
                    if let error = error {
                        testResult = "❌ Firebase read failed: \(error.localizedDescription)"
                    } else if let data = snapshot?.data() {
                        testResult = "✅ Firebase is working perfectly!"
                        userData = data
                    } else {
                        testResult = "❌ No data returned from Firebase"
                    }
                }
            }
        }
    }
}

#Preview {
    FirebaseTestView()
}
