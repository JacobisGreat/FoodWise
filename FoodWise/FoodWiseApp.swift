//
//  FoodWiseApp.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI
import FirebaseCore

@main
struct FoodWiseApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    if authManager.isLoadingProfile {
                        // Show custom loading screen while profile loads
                        LoadingView()
                    } else if authManager.currentUserProfile != nil {
                        // User is authenticated and has profile - show main app
                        MainTabView()
                            .environmentObject(authManager)
                    } else {
                        // User is authenticated but no profile - show onboarding
                        OnboardingView()
                            .environmentObject(authManager)
                    }
                } else {
                    // User not authenticated - show signup
                    SignupView()
                        .environmentObject(authManager)
                }
            }
            .onAppear {
                print("🚀 App launched - Auth status: \(authManager.isAuthenticated)")
                print("👤 Loading profile: \(authManager.isLoadingProfile)")
                if let user = authManager.user {
                    print("👤 Current user: \(user.email ?? "No email")")
                    print("📋 Has profile: \(authManager.currentUserProfile != nil)")
                } else {
                    print("❌ No current user")
                }
            }
            .onChange(of: authManager.isAuthenticated) { _, newValue in
                print("🔄 Auth status changed to: \(newValue)")
            }
            .onChange(of: authManager.currentUserProfile) { _, newValue in
                print("🔄 User profile changed: \(newValue?.name ?? "nil")")
            }
        }
    }
}
