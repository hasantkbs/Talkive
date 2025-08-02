import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var selectedLanguage: String = "en" // Default language
    @Published var isLoading: Bool = false
    
    private var apiService = APIService.shared
    @Published var voiceAssistant = VoiceAssistant()
    
    func sendMessage() async {
        guard !currentMessage.isEmpty else { return }
        
        let userMessage = currentMessage
        messages.append(ChatMessage(text: userMessage, isUser: true))
        currentMessage = ""
        isLoading = true
        
        do {
            let botResponse = try await apiService.getChatResponse(message: userMessage, language: selectedLanguage)
            messages.append(ChatMessage(text: botResponse, isUser: false))
            voiceAssistant.speak(text: botResponse)
        } catch {
            messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false))
        }
        isLoading = false
    }
    
    // Placeholder for voice input
    func sendVoiceMessage(transcribedText: String) async {
        guard !transcribedText.isEmpty else { return }
        
        let userMessage = transcribedText
        messages.append(ChatMessage(text: userMessage, isUser: true))
        isLoading = true
        
        do {
            let botResponse = try await apiService.getChatResponse(message: userMessage, language: selectedLanguage)
            messages.append(ChatMessage(text: botResponse, isUser: false))
            voiceAssistant.speak(text: botResponse)
            // TODO: Speak the response
        } catch {
            messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false))
        }
        isLoading = false
    }
}
