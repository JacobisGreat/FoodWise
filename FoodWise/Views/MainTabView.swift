//
//  MainTabView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

class TabNavigationManager: ObservableObject {
    @Published var selectedTab = 0
}

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var scanHistoryManager = ScanHistoryManager()
    @StateObject private var tabNavigationManager = TabNavigationManager()
    @Namespace private var animationNamespace
    @State private var previousTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch tabNavigationManager.selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(authManager)
                        .environmentObject(scanHistoryManager)
                        .environmentObject(tabNavigationManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab > 0 ? .leading : .trailing).combined(with: .opacity),
                            removal: .move(edge: previousTab > 0 ? .trailing : .leading).combined(with: .opacity)
                        ))
                case 1:
                    HistoryView()
                        .environmentObject(authManager)
                        .environmentObject(scanHistoryManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab > 1 ? .leading : .trailing).combined(with: .opacity),
                            removal: .move(edge: previousTab > 1 ? .trailing : .leading).combined(with: .opacity)
                        ))
                case 2:
                    ProfileView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab > 2 ? .leading : .trailing).combined(with: .opacity),
                            removal: .move(edge: previousTab > 2 ? .trailing : .leading).combined(with: .opacity)
                        ))
                default:
                    HomeView()
                        .environmentObject(authManager)
                        .environmentObject(scanHistoryManager)
                        .environmentObject(tabNavigationManager)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: tabNavigationManager.selectedTab)
            .gesture(
                DragGesture()
                    .onEnded { (gesture: DragGesture.Value) in
                        let threshold: CGFloat = 50
                        let horizontalMovement: CGFloat = gesture.translation.width
                        
                        if horizontalMovement > threshold && tabNavigationManager.selectedTab > 0 {
                            // Swipe right - go to previous tab
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                previousTab = tabNavigationManager.selectedTab
                                tabNavigationManager.selectedTab -= 1
                            }
                        } else if horizontalMovement < -threshold && tabNavigationManager.selectedTab < 2 {
                            // Swipe left - go to next tab
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                previousTab = tabNavigationManager.selectedTab
                                tabNavigationManager.selectedTab += 1
                            }
                        }
                    }
            )
            
            // Custom Tab Bar
            ModernTabBar(selectedTab: $tabNavigationManager.selectedTab, animationNamespace: animationNamespace)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            // Load scan history when the main tab view appears
            if let userId = authManager.user?.uid {
                scanHistoryManager.loadScanHistory(for: userId)
            }
        }
        .onChange(of: tabNavigationManager.selectedTab) { oldValue, newValue in
            previousTab = oldValue
        }
    }
}

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    let animationNamespace: Namespace.ID
    
    private let tabs: [(icon: String, activeIcon: String, title: String)] = [
        ("house", "house.fill", "Discover"),
        ("clock", "clock.fill", "History"),
        ("person", "person.fill", "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabBarButton(
                    icon: tab.icon,
                    activeIcon: tab.activeIcon,
                    title: tab.title,
                    isSelected: selectedTab == index,
                    animationNamespace: animationNamespace,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTab = index
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(Color.white)
                .cornerRadius(0)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let activeIcon: String
    let title: String
    let isSelected: Bool
    let animationNamespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        // Background circle for selected icon
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "selectedTab", in: animationNamespace)
                    }
                    
                    Image(systemName: isSelected ? activeIcon : icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textTertiary)
                        .scaleEffect(1.0)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textTertiary)
                    .opacity(isSelected ? 1.0 : 0.7)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}



#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
