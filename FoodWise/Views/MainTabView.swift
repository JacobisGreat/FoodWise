//
//  MainTabView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    CustomIcons.HomeIcon(size: 24, isActive: selectedTab == 0)
                    Text("Home")
                        .font(.caption)
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    CustomIcons.HistoryIcon(size: 24, isActive: selectedTab == 1)
                    Text("History")
                        .font(.caption)
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    CustomIcons.ProfileIcon(size: 24, isActive: selectedTab == 2)
                    Text("Profile")
                        .font(.caption)
                }
                .tag(2)
        }
        .accentColor(.primaryGreen)
        .accentColor(.primaryGreen)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            
            // Unselected item appearance
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textTertiary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color.textTertiary),
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            // Selected item appearance
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryGreen)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.primaryGreen),
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
