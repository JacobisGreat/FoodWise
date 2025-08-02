//
//  ProfileView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.primaryGreen)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(authManager.currentUserProfile?.name.prefix(1).uppercased() ?? "U")
                                    .font(.titleLarge)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(authManager.currentUserProfile?.name ?? "User")
                                .font(.welcomeTitle)
                                .fontWeight(.medium)
                            
                            Text(authManager.currentUserProfile?.email ?? "")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.top)
                    
                    // Profile Info
                    if let profile = authManager.currentUserProfile {
                        VStack(spacing: 16) {
                            ProfileInfoRow(title: "Age", value: "\(profile.age) years")
                            ProfileInfoRow(title: "Height", value: "\(String(format: "%.0f", profile.height)) cm")
                            ProfileInfoRow(title: "Weight", value: "\(String(format: "%.1f", profile.weight)) kg")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Health Conditions")
                                        .font(.sectionHeader)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                }
                                
                                if profile.medicalConditions.isEmpty {
                                    Text("None specified")
                                        .font(.bodyLarge)
                                } else {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(profile.medicalConditions, id: \.self) { condition in
                                            Text("• \(condition)")
                                                .font(.bodyLarge)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.panelOffWhite)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("Sign Out") {
                            showingSignOutAlert = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    struct ProfileInfoRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.bodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(value)
                    .font(.bodyLarge)
            }
            .padding()
            .background(Color.panelOffWhite)
            .cornerRadius(12)
        }
    }
    
    struct EditProfileView: View {
        @EnvironmentObject var authManager: AuthManager
        @State private var name = ""
        @State private var age = ""
        @State private var height = ""
        @State private var weight = ""
        @State private var selectedConditions: Set<String> = []
        @State private var isLoading = false
        @Environment(\.dismiss) private var dismiss
        
        private let healthConditions = [
            "Diabetes", "Heart Disease", "High Blood Pressure", "High Cholesterol",
            "Obesity", "Food Allergies", "Celiac Disease", "Lactose Intolerance",
            "Kidney Disease", "Liver Disease"
        ]
        
        var body: some View {
            NavigationView {
                Form {
                    Section("Personal Information") {
                        TextField("Name", text: $name)
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.numberPad)
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.numberPad)
                    }
                    
                    Section("Health Conditions") {
                        ForEach(healthConditions, id: \.self) { condition in
                            HStack {
                                Text(condition)
                                Spacer()
                                if selectedConditions.contains(condition) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "#4CAF50"))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedConditions.contains(condition) {
                                    selectedConditions.remove(condition)
                                } else {
                                    selectedConditions.insert(condition)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveProfile()
                        }
                        .disabled(isLoading || !isFormValid)
                    }
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
        
        private var isFormValid: Bool {
            !name.isEmpty && !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
            Int(age) != nil && Double(height) != nil && Double(weight) != nil
        }
        
        private func loadCurrentProfile() {
            guard let profile = authManager.currentUserProfile else { return }
            
            name = profile.name
            age = String(profile.age)
            height = String(format: "%.0f", profile.height)
            weight = String(format: "%.1f", profile.weight)
            selectedConditions = Set(profile.medicalConditions)
        }
        
        private func saveProfile() {
            guard let currentProfile = authManager.currentUserProfile,
                  let ageInt = Int(age),
                  let heightDouble = Double(height),
                  let weightDouble = Double(weight) else { return }
            
            isLoading = true
            
            let updatedProfile = User(
                name: name,
                email: currentProfile.email,
                age: ageInt,
                height: heightDouble,
                weight: weightDouble,
                medicalConditions: Array(selectedConditions)
            )
            
            Task {
                do {
                    try await authManager.updateUserProfile(updatedProfile)
                    DispatchQueue.main.async {
                        self.dismiss()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        // Handle error
                    }
                }
            }
        }
    }}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
