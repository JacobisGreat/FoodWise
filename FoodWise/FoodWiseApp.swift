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
                print("App launched - Auth status: \(authManager.isAuthenticated)")
                if let user = authManager.user {
                    print("Current user: \(user.email ?? "No email")")
                } else {
                    print("No current user")
                }
            }
        }
    }
}
