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
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background matching Discover page
                AnimatedProfileBackground()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 32) {
                        // Modern Profile Header
                        ModernProfileHeader()
                            .environmentObject(authManager)
                        
                        // Profile Stats Cards
                        if let profile = authManager.currentUserProfile {
                            ProfileStatsSection(profile: profile)
                        }
                        
                        // Health Conditions Card
                        if let profile = authManager.currentUserProfile {
                            HealthConditionsCard(profile: profile)
                        }
                        
                        // Action Buttons
                        ProfileActionsSection(
                            showingEditProfile: $showingEditProfile,
                            showingSignOutAlert: $showingSignOutAlert
                        )
                        
                        // Extra spacing for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAnimating = true
            }
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

// MARK: - Supporting Views

struct ProfileInfoRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(value)
                    .font(.body)
            }
            .padding()
            .background(AppColors.panelOffWhite)
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
                                        .foregroundColor(AppColors.primaryGreen)
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
    }

// MARK: - Modern Profile Components

struct AnimatedProfileBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#F8FFFE"),
                    Color(hex: "#E8F5F3"),
                    Color(hex: "#FFFFFF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating orbs
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.primaryGreen.opacity(0.1),
                                AppColors.accentTeal.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .offset(
                        x: animate ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                        y: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 2),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

struct ModernProfileHeader: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Avatar Section
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryGreen.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.primaryGreen,
                                    AppColors.accentTeal
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(String(authManager.currentUserProfile?.name.prefix(1) ?? "U"))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.9)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                }
                
                VStack(spacing: 8) {
                    Text(authManager.currentUserProfile?.name ?? "User")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                    
                    Text(authManager.currentUserProfile?.email ?? "")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: isAnimating)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ProfileStatsSection: View {
    let profile: User
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Profile")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ProfileStatCard(
                    icon: "calendar",
                    title: "Age",
                    value: "\(profile.age)",
                    subtitle: "years",
                    color: AppColors.primaryGreen,
                    delay: 0.1
                )
                
                ProfileStatCard(
                    icon: "ruler",
                    title: "Height",
                    value: String(format: "%.0f", profile.height),
                    subtitle: "cm",
                    color: AppColors.accentTeal,
                    delay: 0.2
                )
                
                ProfileStatCard(
                    icon: "scalemass",
                    title: "Weight",
                    value: String(format: "%.1f", profile.weight),
                    subtitle: "kg",
                    color: AppColors.infoBlue,
                    delay: 0.3
                )
            }
        }
    }
}

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct HealthConditionsCard: View {
    let profile: User
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.warning.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.warning)
                    }
                    
                    Text("Health Conditions")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            if profile.medicalConditions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.primaryGreen)
                    
                    Text("No conditions specified")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(profile.medicalConditions.enumerated()), id: \.offset) { index, condition in
                        ConditionTag(condition: condition, delay: Double(index) * 0.1)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.5), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ConditionTag: View {
    let condition: String
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Text(condition)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(AppColors.primaryGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct ProfileActionsSection: View {
    @Binding var showingEditProfile: Bool
    @Binding var showingSignOutAlert: Bool
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Edit Profile Button
            Button(action: { showingEditProfile = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.pencil")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.accentTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isAnimating)
            
            // Sign Out Button
            Button(action: { showingSignOutAlert = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.warning)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.warning.opacity(0.3), lineWidth: 2)
                        )
                )
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
