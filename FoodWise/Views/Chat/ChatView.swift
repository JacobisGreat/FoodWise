//
//  ChatView.swift
//  FoodWise
//
//  Created by Assistant on 2025-01-27.
//

import SwiftUI
import UIKit

struct ChatView: View {
    @StateObject private var chatManager = ChatManager()
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var scanHistoryManager: ScanHistoryManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var messageText = ""
    @State private var showingConversations = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                ChatHeaderView(
                    showingConversations: $showingConversations,
                    onNewChat: {
                        chatManager.startNewConversation()
                    },
                    onDismiss: {
                        dismiss()
                    }
                )
                
                // Messages
                MessagesView(
                    conversation: chatManager.currentConversation,
                    isLoading: chatManager.isLoading
                )
                
                // Input Area
                MessageInputView(
                    messageText: $messageText,
                    isLoading: chatManager.isLoading,
                    onSend: {
                        sendMessage()
                    }
                )
                .focused($isTextFieldFocused)
            }
            .background(AppColors.backgroundWhite)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingConversations) {
            ConversationListView(chatManager: chatManager)
        }
        .onAppear {
            // Small delay to ensure smooth animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        messageText = ""
        
        Task {
            await chatManager.sendMessage(
                message,
                userProfile: authManager.currentUserProfile,
                scanHistory: scanHistoryManager.scanHistory
            )
        }
    }
}

// MARK: - Chat Header

struct ChatHeaderView: View {
    @Binding var showingConversations: Bool
    let onNewChat: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            // Close button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.panelOffWhite)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Title with AI icon
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                
                Text("FoodWise AI")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            // Menu button
            Button(action: { showingConversations = true }) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.panelOffWhite)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.backgroundWhite)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Messages View

struct MessagesView: View {
    let conversation: ChatConversation?
    let isLoading: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let conversation = conversation {
                        ForEach(conversation.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    
                    // Loading indicator
                    if isLoading {
                        TypingIndicatorView()
                            .id("typing")
                    }
                    
                    // Bottom spacing
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .onChange(of: conversation?.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    if isLoading {
                        proxy.scrollTo("typing", anchor: .bottom)
                    } else if let lastMessage = conversation?.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: isLoading) { _, newValue in
                if newValue {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Text(timeAgoDisplay(for: message.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 12) {
                        // AI Avatar
                        ZStack {
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
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Message content
                        VStack(alignment: .leading, spacing: 8) {
                            Text(message.content)
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Message type indicator
                            MessageTypeIndicator(messageType: message.messageType)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.panelOffWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        Spacer(minLength: 60)
                    }
                    
                    Text(timeAgoDisplay(for: message.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.leading, 44)
                }
            }
        }
    }
    
    private func timeAgoDisplay(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Message Type Indicator

struct MessageTypeIndicator: View {
    let messageType: ChatMessage.MessageType
    
    var body: some View {
        if messageType != .text {
            HStack(spacing: 4) {
                Image(systemName: iconForMessageType)
                    .font(.system(size: 10, weight: .semibold))
                Text(labelForMessageType)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(colorForMessageType)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForMessageType.opacity(0.1))
            .clipShape(Capsule())
        }
    }
    
    private var iconForMessageType: String {
        switch messageType {
        case .healthTip: return "lightbulb"
        case .scanSummary: return "barcode.viewfinder"
        case .nutritionAdvice: return "leaf"
        case .greeting: return "hand.wave"
        case .text: return "message"
        }
    }
    
    private var labelForMessageType: String {
        switch messageType {
        case .healthTip: return "Health Tip"
        case .scanSummary: return "Scan Summary"
        case .nutritionAdvice: return "Nutrition"
        case .greeting: return "Greeting"
        case .text: return "Message"
        }
    }
    
    private var colorForMessageType: Color {
        switch messageType {
        case .healthTip: return AppColors.warning
        case .scanSummary: return AppColors.primaryGreen
        case .nutritionAdvice: return AppColors.accentTeal
        case .greeting: return AppColors.infoBlue
        case .text: return AppColors.textSecondary
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    @State private var glowPhase = false
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 12) {
                // AI Avatar with enhanced glow
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(AppColors.primaryGreen.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .scaleEffect(glowPhase ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                            value: glowPhase
                        )
                    
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
                        .frame(width: 32, height: 32)
                        .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(glowPhase ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                            value: glowPhase
                        )
                }
                
                // Enhanced typing dots with wave effect
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppColors.primaryGreen.opacity(0.7))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationPhase == index ? 1.4 : 0.6)
                            .opacity(animationPhase == index ? 1.0 : 0.4)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                                value: animationPhase
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.panelOffWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.primaryGreen.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                Spacer(minLength: 60)
            }
            
            Spacer()
        }
        .onAppear {
            animationPhase = 0
            glowPhase = true
            
            // Cycle through dots continuously
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Message Input

struct MessageInputView: View {
    @Binding var messageText: String
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppColors.textTertiary.opacity(0.2))
            
            HStack(spacing: 12) {
                // Text input
                HStack(spacing: 12) {
                    TextField("Message FoodWise AI...", text: $messageText, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1...6)
                        .onSubmit {
                            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSend()
                            }
                        }
                    
                    // Send button
                    Button(action: onSend) {
                        ZStack {
                            Circle()
                                .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                      AppColors.textTertiary.opacity(0.3) : AppColors.primaryGreen)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.panelOffWhite)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(AppColors.backgroundWhite)
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AuthManager())
        .environmentObject(ScanHistoryManager())
}