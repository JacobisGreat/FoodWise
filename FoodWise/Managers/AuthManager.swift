//
//  AuthManager.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var currentUserProfile: User?
    @Published var isLoadingProfile = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Start with loading state
        isLoadingProfile = true
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    print("User signed in: \(user.email ?? "No email"), UID: \(user.uid)")
                    // Keep loading state true while we fetch profile
                    self?.loadUserProfile(userId: user.uid)
                } else {
                    print("User signed out")
                    self?.currentUserProfile = nil
                    self?.isLoadingProfile = false
                }
            }
        }
        
        // Add minimum loading time to prevent flicker
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.user == nil {
                self.isLoadingProfile = false
            }
        }
    }
    
    func signUp(email: String, password: String, name: String, age: Int, height: Double, weight: Double, medicalConditions: [String]) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let userProfile = User(
            id: result.user.uid,
            name: name,
            email: email,
            age: age,
            height: height,
            weight: weight,
            medicalConditions: medicalConditions
        )
        
        // Convert to dictionary for Firestore
        let userData: [String: Any] = [
            "name": userProfile.name,
            "email": userProfile.email,
            "age": userProfile.age,
            "height": userProfile.height,
            "weight": userProfile.weight,
            "medicalConditions": userProfile.medicalConditions,
            "createdAt": userProfile.createdAt
        ]
        
        try await db.collection("users").document(result.user.uid).setData(userData)
        
        DispatchQueue.main.async {
            self.currentUserProfile = userProfile
            self.isLoadingProfile = false
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUserProfile = nil
        }
    }
    
    private func loadUserProfile(userId: String) {
        print("Loading user profile for userId: \(userId)")
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user profile: \(error)")
                DispatchQueue.main.async {
                    // If there's an error, the user might need to complete onboarding
                    self?.currentUserProfile = nil
                    self?.isLoadingProfile = false
                }
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("User profile not found for userId: \(userId)")
                print("User needs to complete onboarding")
                DispatchQueue.main.async {
                    // Profile doesn't exist - user needs to complete onboarding
                    self?.currentUserProfile = nil
                    self?.isLoadingProfile = false
                }
                return
            }
            
            guard let data = snapshot.data() else {
                print("No data in user profile document")
                DispatchQueue.main.async {
                    self?.currentUserProfile = nil
                    self?.isLoadingProfile = false
                }
                return
            }
            
            do {
                // Manually decode the user profile
                let userProfile = User(
                    id: userId,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    age: data["age"] as? Int ?? 0,
                    height: data["height"] as? Double ?? 0.0,
                    weight: data["weight"] as? Double ?? 0.0,
                    medicalConditions: data["medicalConditions"] as? [String] ?? []
                )
                
                DispatchQueue.main.async {
                    self?.currentUserProfile = userProfile
                    self?.isLoadingProfile = false
                    print("User profile loaded successfully: \(userProfile.name)")
                }
            } catch {
                print("Error decoding user profile: \(error)")
                DispatchQueue.main.async {
                    self?.currentUserProfile = nil
                    self?.isLoadingProfile = false
                }
            }
        }
    }
    
    func updateUserProfile(_ updatedUser: User) async throws {
        guard let userId = user?.uid else { 
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]) 
        }
        
        print("Saving user profile for userId: \(userId)")
        
        let userData: [String: Any] = [
            "name": updatedUser.name,
            "email": updatedUser.email,
            "age": updatedUser.age,
            "height": updatedUser.height,
            "weight": updatedUser.weight,
            "medicalConditions": updatedUser.medicalConditions,
            "createdAt": updatedUser.createdAt
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
        print("User profile saved successfully")
        
        DispatchQueue.main.async {
            var userWithId = updatedUser
            userWithId.id = userId
            self.currentUserProfile = userWithId
            print("User profile updated in memory: \(userWithId.name)")
        }
    }
}
