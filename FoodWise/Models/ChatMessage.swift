//
//  ChatMessage.swift
//  FoodWise
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    enum MessageType: String, Codable, CaseIterable {
        case text = "text"
        case healthTip = "health_tip"
        case scanSummary = "scan_summary"
        case nutritionAdvice = "nutrition_advice"
        case greeting = "greeting"
    }
    
    init(content: String, isUser: Bool, messageType: MessageType = .text) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.messageType = messageType
    }
}

// Chat conversation container
struct ChatConversation: Identifiable, Codable {
    let id = UUID()
    var messages: [ChatMessage]
    let createdAt: Date
    var lastUpdated: Date
    var title: String
    
    init(title: String = "New Conversation") {
        self.messages = []
        self.createdAt = Date()
        self.lastUpdated = Date()
        self.title = title
    }
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        lastUpdated = Date()
        
        // Auto-generate title from first user message
        if title == "New Conversation" && message.isUser && !message.content.isEmpty {
            title = String(message.content.prefix(30)) + (message.content.count > 30 ? "..." : "")
        }
    }
}