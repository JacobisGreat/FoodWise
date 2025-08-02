//
//  LoginView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.7, blue: 0.3),
                        Color(red: 0.2, green: 0.8, blue: 0.4),
                        Color(red: 0.0, green: 0.6, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 60)
                        
                        // Logo and Title
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Welcome Back")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Sign in to continue your healthy journey")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Form Card
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                ModernTextField(
                                    placeholder: "Email",
                                    text: $email,
                                    icon: "envelope.fill",
                                    keyboardType: .emailAddress
                                )
                                
                                ModernSecureField(
                                    placeholder: "Password",
                                    text: $password,
                                    icon: "lock.fill"
                                )
                                
                                if !errorMessage.isEmpty {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            
                            // Sign In Button
                            Button(action: signIn) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 18, weight: .medium))
                                        Text("Sign In")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.0, green: 0.5, blue: 0.2), Color(red: 0.1, green: 0.6, blue: 0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isLoading || !isFormValid)
                            .opacity((!isFormValid && !isLoading) ? 0.6 : 1.0)
                            
                            // Reset Password Link
                            Button(action: resetPassword) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .underline()
                            }
                        }
                        .padding(28)
                        .background(.white.opacity(0.15))
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Cancel")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func signIn() {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("🔐 Attempting to sign in with email: \(email)")
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                print("✅ Sign in successful")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                print("❌ Sign in failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email first"
            return
        }
        
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                DispatchQueue.main.async {
                    self.errorMessage = "Password reset email sent! Check your inbox."
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error sending reset email: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
