//
//  ChatManager.swift
//  FoodWise
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class ChatManager: ObservableObject {
    @Published var conversations: [ChatConversation] = []
    @Published var currentConversation: ChatConversation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiManager = APIManager()
    
    init() {
        loadConversations()
        createWelcomeConversation()
    }
    
    // MARK: - Conversation Management
    
    func startNewConversation() {
        let newConversation = ChatConversation(title: "New Conversation")
        conversations.insert(newConversation, at: 0)
        currentConversation = newConversation
        saveConversations()
    }
    
    func selectConversation(_ conversation: ChatConversation) {
        currentConversation = conversation
    }
    
    func deleteConversation(_ conversation: ChatConversation) {
        conversations.removeAll { $0.id == conversation.id }
        if currentConversation?.id == conversation.id {
            currentConversation = conversations.first
        }
        saveConversations()
    }
    
    // MARK: - Message Handling
    
    func sendMessage(_ content: String, userProfile: User?, scanHistory: [ScanResult] = []) async {
        guard !content.isEmpty else { return }
        
        // Create or update current conversation
        if currentConversation == nil {
            startNewConversation()
        }
        
        guard var conversation = currentConversation else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: content, isUser: true)
        conversation.addMessage(userMessage)
        updateCurrentConversation(conversation)
        
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate AI response with health context
            let aiResponse = try await generateAIResponse(
                message: content,
                conversation: conversation,
                userProfile: userProfile,
                scanHistory: scanHistory
            )
            
            // Add AI response
            let aiMessage = ChatMessage(
                content: aiResponse.content,
                isUser: false,
                messageType: aiResponse.messageType
            )
            conversation.addMessage(aiMessage)
            updateCurrentConversation(conversation)
            
        } catch {
            errorMessage = "Failed to get response: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func updateCurrentConversation(_ conversation: ChatConversation) {
        currentConversation = conversation
        
        // Update in conversations array
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        }
        
        saveConversations()
    }
    
    // MARK: - AI Response Generation
    
    private func generateAIResponse(
        message: String,
        conversation: ChatConversation,
        userProfile: User?,
        scanHistory: [ScanResult]
    ) async throws -> (content: String, messageType: ChatMessage.MessageType) {
        
        let prompt = createChatPrompt(
            userMessage: message,
            conversation: conversation,
            userProfile: userProfile,
            scanHistory: scanHistory
        )
        
        // Use Gemini API for response
        let geminiResult = try await apiManager.sendGeminiChatRequest(prompt: prompt)
        
        // Determine message type based on content
        let messageType = determineMessageType(response: geminiResult)
        
        return (content: geminiResult, messageType: messageType)
    }
    
    private func createChatPrompt(
        userMessage: String,
        conversation: ChatConversation,
        userProfile: User?,
        scanHistory: [ScanResult]
    ) -> String {
        var prompt = """
        You are FoodWise AI, a personal nutrition and health assistant. You are helpful, friendly, and knowledgeable about nutrition, health, and food choices.
        
        PERSONALITY:
        - Be conversational and warm, like a knowledgeable friend
        - Use emojis sparingly but effectively
        - Keep responses concise but informative
        - Be encouraging and supportive about health goals
        - Provide actionable advice when appropriate
        
        """
        
        // Add user profile context
        if let user = userProfile {
            prompt += """
            
            USER PROFILE:
            - Name: \(user.name)
            - Age: \(user.age)
            - Height: \(user.height)cm, Weight: \(user.weight)kg
            - Health Conditions: \(user.medicalConditions.isEmpty ? "None specified" : user.medicalConditions.joined(separator: ", "))
            - Goals: Maintain healthy eating habits
            """
        }
        
        // Add scan history context
        if !scanHistory.isEmpty {
            let recentScans = scanHistory.prefix(5)
            prompt += """
            
            RECENT FOOD SCANS:
            """
            for scan in recentScans {
                prompt += "\n- \(scan.productName): NutriScore \(scan.nutriScore)"
            }
        }
        
        // Add conversation history (last 10 messages for context)
        let recentMessages = conversation.messages.suffix(10)
        if !recentMessages.isEmpty {
            prompt += """
            
            CONVERSATION HISTORY:
            """
            for message in recentMessages {
                let role = message.isUser ? "User" : "Assistant"
                prompt += "\n\(role): \(message.content)"
            }
        }
        
        prompt += """
        
        USER MESSAGE: \(userMessage)
        
        RESPONSE FORMAT:
        - Use plain text only, no markdown formatting (no *, **, _, __, etc.)
        - Write naturally without special formatting
        - Keep responses conversational and easy to read
        
        Please respond naturally and helpfully. If the user asks about nutrition, health, food choices, or their scan history, provide relevant advice. If they ask general questions, answer them while keeping the conversation friendly and on-topic when possible.
        """
        
        return prompt
    }
    
    private func determineMessageType(response: String) -> ChatMessage.MessageType {
        let lowercased = response.lowercased()
        
        if lowercased.contains("tip") || lowercased.contains("advice") {
            return .healthTip
        } else if lowercased.contains("scan") || lowercased.contains("nutriscore") {
            return .scanSummary
        } else if lowercased.contains("nutrition") || lowercased.contains("vitamin") || lowercased.contains("mineral") {
            return .nutritionAdvice
        } else if lowercased.contains("hello") || lowercased.contains("hi") || lowercased.contains("welcome") {
            return .greeting
        }
        
        return .text
    }
    
    // MARK: - Persistence
    
    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: "chat_conversations")
        }
    }
    
    private func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: "chat_conversations"),
           let decoded = try? JSONDecoder().decode([ChatConversation].self, from: data) {
            conversations = decoded
        }
    }
    
    private func createWelcomeConversation() {
        if conversations.isEmpty {
            var welcomeConversation = ChatConversation(title: "Welcome to FoodWise AI")
            
            let welcomeMessage = ChatMessage(
                content: "👋 Hi there! I'm your personal FoodWise AI assistant. I'm here to help you make healthier food choices, understand nutrition labels, and answer any questions about your diet and health.\n\nYou can ask me about:\n• Nutrition advice\n• Your scan history\n• Healthy recipe suggestions\n• Ingredient information\n• And much more!\n\nHow can I help you today?",
                isUser: false,
                messageType: .greeting
            )
            
            welcomeConversation.addMessage(welcomeMessage)
            conversations.append(welcomeConversation)
            currentConversation = welcomeConversation
            saveConversations()
        } else if currentConversation == nil {
            currentConversation = conversations.first
        }
    }
}

// MARK: - APIManager Extension for Chat

extension APIManager {
    func sendGeminiChatRequest(prompt: String) async throws -> String {
        print("🤖 Sending Gemini chat request...")
        let url = URL(string: "\(geminiBaseURL)?key=\(geminiAPIKey)")!
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1000,
                "topP": 0.9,
                "topK": 40
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Gemini Chat Response Status: \(httpResponse.statusCode)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("📦 Gemini Chat Raw Response: \(responseString)")
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let responseText = geminiResponse.candidates.first?.content.parts.first?.text else {
            print("❌ No response text from Gemini chat")
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from Gemini"])
        }
        
        print("✅ Gemini Chat Response: \(responseText)")
        
        // Clean any markdown formatting from the response
        let cleanedResponse = cleanMarkdownFromText(responseText)
        
        return cleanedResponse
    }
    
    private func cleanMarkdownFromText(_ text: String) -> String {
        return text
            // Remove bold formatting
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            // Remove italic formatting
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            // Remove inline code formatting
            .replacingOccurrences(of: "`", with: "")
            // Remove strikethrough
            .replacingOccurrences(of: "~~", with: "")
            // Clean up any double spaces that might result
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}