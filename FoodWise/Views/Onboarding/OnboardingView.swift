//
//  OnboardingView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var currentStep = 0
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var selectedConditions: Set<String> = []
    @State private var customCondition = ""
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    
    private let healthConditions = [
        "Diabetes", "Heart Disease", "High Blood Pressure", "High Cholesterol",
        "Obesity", "Food Allergies", "Celiac Disease", "Lactose Intolerance",
        "Kidney Disease", "Liver Disease", "None"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Bar
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#4CAF50")))
                    .padding()
                
                TabView(selection: $currentStep) {
                    // Step 1: Health Conditions
                    VStack(spacing: 24) {
                        Text("Select any health conditions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("This helps us provide personalized food recommendations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(healthConditions, id: \.self) { condition in
                                Button(action: {
                                    if condition == "None" {
                                        selectedConditions.removeAll()
                                        selectedConditions.insert("None")
                                    } else {
                                        selectedConditions.remove("None")
                                        if selectedConditions.contains(condition) {
                                            selectedConditions.remove(condition)
                                        } else {
                                            selectedConditions.insert(condition)
                                        }
                                    }
                                }) {
                                    Text(condition)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedConditions.contains(condition) ?
                                            Color(hex: "#4CAF50") : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            selectedConditions.contains(condition) ? .white : .primary
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Custom condition input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Or add a custom condition/notes:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            HStack {
                                TextField("e.g., Gluten sensitivity, Low sodium diet", text: $customCondition)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Add") {
                                    if !customCondition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        selectedConditions.remove("None")
                                        selectedConditions.insert(customCondition.trimmingCharacters(in: .whitespacesAndNewlines))
                                        customCondition = ""
                                    }
                                }
                                .disabled(customCondition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    customCondition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                    Color.gray.opacity(0.3) : Color(hex: "#4CAF50")
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .tag(0)
                    
                    // Step 2: Basic Info
                    VStack(spacing: 24) {
                        Text("Tell us about yourself")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Age")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter your age", text: $age)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Height (cm)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter your height", text: $height)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weight (kg)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter your weight", text: $weight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .tag(1)
                    
                    // Step 3: Complete
                    VStack(spacing: 24) {
                        if isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(Color(hex: "#4CAF50"))
                                
                                Text("Setting up your profile...")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text("Personalizing your FoodWise experience")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "#4CAF50"))
                            
                            Text("You're all set!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Start making smarter food choices with FoodWise")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    
                    Button(currentStep == 2 ? "Get Started" : "Continue") {
                        if currentStep == 2 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        (currentStep == 0 && selectedConditions.isEmpty) ||
                        (currentStep == 1 && !isBasicInfoValid) ?
                        Color.gray.opacity(0.3) : Color(hex: "#4CAF50")
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(
                        (currentStep == 0 && selectedConditions.isEmpty) ||
                        (currentStep == 1 && !isBasicInfoValid) ||
                        isLoading
                    )
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        showingSignOutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out and start over?")
            }
        }
    }
    
    private var isBasicInfoValid: Bool {
        !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
        Int(age) != nil && Double(height) != nil && Double(weight) != nil
    }
    
    private func completeOnboarding() {
        guard let ageInt = Int(age),
              let heightDouble = Double(height),
              let weightDouble = Double(weight),
              let currentUser = authManager.user else { 
            print("Invalid form data or no authenticated user")
            return 
        }
        
        isLoading = true
        
        let conditions = selectedConditions.contains("None") ? [] : Array(selectedConditions)
        
        let updatedUser = User(
            id: currentUser.uid,
            name: currentUser.displayName ?? currentUser.email ?? "User",
            email: currentUser.email ?? "",
            age: ageInt,
            height: heightDouble,
            weight: weightDouble,
            medicalConditions: conditions
        )
        
        print("🏁 Creating user profile for: \(updatedUser.name)")
        print("📋 Profile data: Age \(updatedUser.age), Height \(updatedUser.height), Weight \(updatedUser.weight)")
        print("💊 Medical conditions: \(updatedUser.medicalConditions)")
        
        Task {
            do {
                try await authManager.updateUserProfile(updatedUser)
                print("✅ User profile created successfully")
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("🔄 Onboarding completed, should navigate to main app")
                    // Profile is now set, app will automatically navigate to main view
                }
            } catch {
                print("❌ Error creating user profile: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Handle error - maybe show alert
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
