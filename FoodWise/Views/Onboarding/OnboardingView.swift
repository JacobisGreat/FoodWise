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
    @State private var customConditions: [String] = []
    @State private var newCustomCondition = ""
    @State private var healthGoals = ""
    @State private var additionalHealthConcerns = ""
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    @State private var showingAddCustomCondition = false
    
    private let healthConditions = [
        "Diabetes", "Heart Disease", "High Blood Pressure", "High Cholesterol",
        "Obesity", "Food Allergies", "Celiac Disease", "Lactose Intolerance",
        "Kidney Disease", "Liver Disease", "Arthritis", "Osteoporosis",
        "IBS/IBD", "GERD", "Thyroid Issues"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: Double(currentStep + 1), total: 5)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryGreen))
                    .padding()
                    .background(AppColors.backgroundWhite)
                
                TabView(selection: $currentStep) {
                    // Step 1: Health Conditions
                    healthConditionsStep()
                        .tag(0)
                    
                    // Step 2: Custom Conditions & Additional Concerns
                    customHealthStep()
                        .tag(1)
                    
                    // Step 3: Health Goals
                    healthGoalsStep()
                        .tag(2)
                    
                    // Step 4: Basic Info
                    basicInfoStep()
                        .tag(3)
                    
                    // Step 5: Complete
                    completionStep()
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                navigationButtons()
            }
            .background(AppColors.backgroundWhite)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        showingSignOutAlert = true
                    }
                    .foregroundColor(AppColors.dangerRed)
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
            .sheet(isPresented: $showingAddCustomCondition) {
                addCustomConditionSheet()
            }
        }
    }
    
    // MARK: - Step Views
    
    private func healthConditionsStep() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Select Health Conditions")
                        .font(AppFonts.heading1)
                        .foregroundColor(AppColors.darkGrayText)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose any that apply to you")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.mediumGrayText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(healthConditions, id: \.self) { condition in
                        ConditionCard(
                            condition: condition,
                            isSelected: selectedConditions.contains(condition)
                        ) {
                            toggleCondition(condition)
                        }
                    }
                    
                    // Add custom condition button
                    Button(action: {
                        showingAddCustomCondition = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Other")
                        }
                        .font(AppFonts.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.offWhitePanels)
                        .foregroundColor(AppColors.primaryGreen)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.primaryGreen, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Display custom conditions
                if !customConditions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Custom Conditions:")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.mediumGrayText)
                        
                        ForEach(customConditions, id: \.self) { condition in
                            HStack {
                                Text(condition)
                                    .font(AppFonts.caption)
                                Spacer()
                                Button(action: {
                                    customConditions.removeAll { $0 == condition }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.dangerRed)
                                }
                            }
                            .padding(8)
                            .background(AppColors.offWhitePanels)
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func customHealthStep() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Additional Health Information")
                        .font(AppFonts.heading1)
                        .foregroundColor(AppColors.darkGrayText)
                        .multilineTextAlignment(.center)
                    
                    Text("Share any other health concerns or details")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.mediumGrayText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Health Concerns")
                            .font(AppFonts.heading2)
                            .foregroundColor(AppColors.darkGrayText)
                        
                        Text("Describe any health concerns, symptoms, or sensitivities you have")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.mediumGrayText)
                        
                        TextEditor(text: $additionalHealthConcerns)
                            .frame(minHeight: 100)
                            .padding(10)
                            .background(AppColors.backgroundWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.dividerGray, lineWidth: 1)
                            )
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func healthGoalsStep() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Your Health Goals")
                        .font(AppFonts.heading1)
                        .foregroundColor(AppColors.darkGrayText)
                        .multilineTextAlignment(.center)
                    
                    Text("Tell us about your health and wellness goals")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.mediumGrayText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Life & Health Goals")
                            .font(AppFonts.heading2)
                            .foregroundColor(AppColors.darkGrayText)
                        
                        Text("Examples: Lose weight, build muscle, manage diabetes, improve energy, reduce inflammation, eat cleaner")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.mediumGrayText)
                        
                        TextEditor(text: $healthGoals)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(AppColors.backgroundWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.dividerGray, lineWidth: 1)
                            )
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func basicInfoStep() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Enter Your Details")
                        .font(AppFonts.heading1)
                        .foregroundColor(AppColors.darkGrayText)
                    
                    Text("This helps us provide personalized recommendations")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.mediumGrayText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    CustomTextField(title: "Age", text: $age, keyboardType: .numberPad)
                    
                    HStack(spacing: 12) {
                        CustomTextField(title: "Height (cm)", text: $height, keyboardType: .numberPad)
                        CustomTextField(title: "Weight (kg)", text: $weight, keyboardType: .numberPad)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func completionStep() -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.successGreen)
            
            VStack(spacing: 12) {
                Text("You're All Set!")
                    .font(AppFonts.heading1)
                    .foregroundColor(AppColors.darkGrayText)
                
                Text("Start making smarter food choices with personalized recommendations")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.mediumGrayText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private func navigationButtons() -> some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppColors.offWhitePanels)
                .foregroundColor(AppColors.darkGrayText)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.dividerGray, lineWidth: 1)
                )
                .cornerRadius(10)
            }
            
            Button(currentStep == 4 ? "Get Started" : "Continue") {
                if currentStep == 4 {
                    completeOnboarding()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(canProceed ? AppColors.primaryGreen : AppColors.mediumGrayText.opacity(0.3))
            .foregroundColor(.white)
            .font(AppFonts.buttonText)
            .cornerRadius(10)
            .disabled(!canProceed || isLoading)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryGreen))
                    .scaleEffect(0.8)
            }
        }
        .padding()
    }
    
    private func addCustomConditionSheet() -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Custom Health Condition")
                    .font(AppFonts.heading2)
                    .foregroundColor(AppColors.darkGrayText)
                
                CustomTextField(title: "Condition Name", text: $newCustomCondition, keyboardType: .default)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newCustomCondition = ""
                        showingAddCustomCondition = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !newCustomCondition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            customConditions.append(newCustomCondition.trimmingCharacters(in: .whitespacesAndNewlines))
                            newCustomCondition = ""
                            showingAddCustomCondition = false
                        }
                    }
                    .disabled(newCustomCondition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true // Health conditions are optional
        case 1: return true // Additional health concerns are optional
        case 2: return true // Health goals are optional
        case 3: return isBasicInfoValid
        case 4: return true
        default: return false
        }
    }
    
    private var isBasicInfoValid: Bool {
        !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
        Int(age) != nil && Double(height) != nil && Double(weight) != nil
    }
    
    private func toggleCondition(_ condition: String) {
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
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
        
        let allConditions = Array(selectedConditions)
        
        let updatedUser = User(
            id: currentUser.uid,
            name: currentUser.displayName ?? currentUser.email ?? "User",
            email: currentUser.email ?? "",
            age: ageInt,
            height: heightDouble,
            weight: weightDouble,
            medicalConditions: allConditions,
            customHealthConditions: customConditions,
            healthGoals: healthGoals.trimmingCharacters(in: .whitespacesAndNewlines),
            additionalHealthConcerns: additionalHealthConcerns.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        print("Creating user profile for: \(updatedUser.name)")
        
        Task {
            do {
                try await authManager.updateUserProfile(updatedUser)
                print("User profile created successfully")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Profile is now set, app will automatically navigate to main view
                }
            } catch {
                print("Error creating user profile: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Handle error - maybe show alert
                }
            }
        }
    }
}

// MARK: - Custom Components

struct ConditionCard: View {
    let condition: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(condition)
                    .font(AppFonts.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primaryGreen : AppColors.offWhitePanels)
            .foregroundColor(isSelected ? .white : AppColors.darkGrayText)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? AppColors.primaryGreen : AppColors.dividerGray, lineWidth: 1)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.darkGrayText)
            
            TextField("Enter \(title.lowercased())", text: $text)
                .font(AppFonts.body)
                .padding(15)
                .background(AppColors.backgroundWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(text.isEmpty ? AppColors.dividerGray : AppColors.primaryGreen, lineWidth: 1)
                )
                .cornerRadius(10)
                .keyboardType(keyboardType)
        }
    }
}

#Preview {
    OnboardingView()
}
