//
//  ConversationListView.swift
//  FoodWise
//
//  Created by Assistant on 2025-01-27.
//

import SwiftUI

struct ConversationListView: View {
    @ObservedObject var chatManager: ChatManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Conversations")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(AppColors.textTertiary.opacity(0.2))
                
                // New conversation button
                Button(action: {
                    chatManager.startNewConversation()
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                        
                        Text("New Conversation")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(AppColors.panelOffWhite)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Conversations list
                if chatManager.conversations.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("No conversations yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Start a new conversation to chat with FoodWise AI")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(chatManager.conversations) { conversation in
                                ConversationRowView(
                                    conversation: conversation,
                                    isSelected: conversation.id == chatManager.currentConversation?.id,
                                    onSelect: {
                                        chatManager.selectConversation(conversation)
                                        dismiss()
                                    },
                                    onDelete: {
                                        chatManager.deleteConversation(conversation)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
                
                Spacer()
            }
            .background(AppColors.backgroundWhite)
            .navigationBarHidden(true)
        }
    }
}

struct ConversationRowView: View {
    let conversation: ChatConversation
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Conversation icon
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primaryGreen : AppColors.textTertiary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textTertiary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    if let lastMessage = conversation.messages.last {
                        Text(lastMessage.content)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Text(timeAgoDisplay(for: conversation.lastUpdated))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.error)
                        .frame(width: 32, height: 32)
                        .background(AppColors.error.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primaryGreen.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgoDisplay(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ConversationListView(chatManager: ChatManager())
}