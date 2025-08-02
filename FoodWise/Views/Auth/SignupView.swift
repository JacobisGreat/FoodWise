//
//  SignupView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showingLogin = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        AppColors.primaryGreen.opacity(0.05),
                        AppColors.primaryGreen.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Enhanced Logo and Title
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primaryGreen.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppColors.primaryGreen)
                                    .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Welcome to FoodWise")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Your journey to healthier eating starts here")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Modern Form Card
                        VStack(spacing: 20) {
                            ModernTextField(
                                placeholder: "Full Name",
                                text: $name,
                                icon: "person.fill"
                            )
                            
                            ModernTextField(
                                placeholder: "Email Address",
                                text: $email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            ModernSecureField(
                                placeholder: "Password",
                                text: $password,
                                icon: "lock.fill"
                            )
                            
                            ModernSecureField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                icon: "lock.fill"
                            )
                            
                            if !errorMessage.isEmpty {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Enhanced Sign Up Button
                        VStack(spacing: 16) {
                            Button(action: {
            isLoading = true
            Task {
                do {
                    try await authManager.signUpForOnboarding(email: email, password: password, name: name)
                    print("✅ Account created successfully - proceeding to onboarding")
                } catch {
                    print("❌ Signup error: \(error)")
                    self.errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                        Text("Create Account")
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.primaryGreen,
                                        AppColors.primaryGreen.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                            .scaleEffect(isLoading ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3), value: isLoading)
                            .disabled(isLoading || !isFormValid)
                            .padding(.horizontal, 24)
                            
                            // Login Link
                            Button("Already have an account? Sign In") {
                                showingLogin = true
                            }
                            .foregroundColor(AppColors.primaryGreen)
                            .font(.body)
                            .fontWeight(.medium)
                        }
                        
                        // Development helper (only show in debug)
                        #if DEBUG
                        Button("🧪 Fill Test Data") {
                            fillTestData()
                        }
                        .foregroundColor(AppColors.textTertiary)
                        .font(.caption)
                        #endif
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
                .environmentObject(authManager)
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
    
    private func signUp() {
        guard isFormValid else {
            if name.isEmpty {
                errorMessage = "Please enter your name"
            } else if email.isEmpty {
                errorMessage = "Please enter your email"
            } else if password.isEmpty {
                errorMessage = "Please enter a password"
            } else if password != confirmPassword {
                errorMessage = "Passwords don't match"
            } else if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
            } else {
                errorMessage = "Please fill all fields correctly"
            }
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("📝 Attempting to sign up with email: \(email), name: \(name)")
        
        Task {
            do {
                // Create account WITHOUT profile - onboarding will handle profile creation
                try await authManager.signUpForOnboarding(
                    email: email,
                    password: password,
                    name: name
                )
                
                print("✅ Sign up successful, account created without profile")
                print("🎯 App should now show onboarding automatically")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // No need to set showingOnboarding - the app will detect no profile and show onboarding
                }
            } catch {
                print("❌ Sign up failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fillTestData() {
        name = "Test User"
        email = "test@foodwise.com"
        password = "test123"
        confirmPassword = "test123"
    }
}

// MARK: - Modern UI Components

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.primaryGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.primaryGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    SignupView()
}
