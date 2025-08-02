import SwiftUI

struct ChatScreen: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingSettingsSheet = false
    @State private var showingTalkModeSheet = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Theme-Aware Colors

    private var effectiveColorScheme: ColorScheme {
        if settingsViewModel.selectedTheme == .system {
            return colorScheme
        }
        return settingsViewModel.selectedTheme == .dark ? .dark : .light
    }

    private var languageSelectorBackground: Color {
        return effectiveColorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6)
    }

    private var userBubbleColor: Color {
        return .blue // Consistently blue for user
    }

    private var userTextColor: Color {
        return .white
    }

    private var aiBubbleColor: Color {
        if effectiveColorScheme == .dark {
            return .white // Per user request
        } else {
            return Color(UIColor.systemGray5)
        }
    }

    private var aiTextColor: Color {
        return .black // Per user request for dark mode, also works for light mode
    }
    
    private var typingIndicatorColor: Color {
        return effectiveColorScheme == .dark ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5)
    }

    private var sendButtonColor: Color {
        return .blue
    }

    

    // MARK: - Body

    var body: some View {
        VStack {

            chatMessagesView
            messageInputView
        }
        .navigationTitle("Talkive Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsScreen()
                .environmentObject(authViewModel)
                .environmentObject(settingsViewModel) // Pass it down
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onChange(of: viewModel.voiceAssistant.transcribedText) { newText in
            if viewModel.voiceAssistant.isRecording {
                viewModel.currentMessage = newText // Update text field with live transcription
            }
        }
    }

    // MARK: - Subviews

    

    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                            }
                            Text(message.text)
                                .padding(10)
                                .background(message.isUser ? userBubbleColor : aiBubbleColor)
                                .foregroundColor(message.isUser ? userTextColor : aiTextColor)
                                .cornerRadius(10)
                            if !message.isUser {
                                Spacer()
                            }
                        }
                        .id(message.id)
                    }
                    if viewModel.isLoading {
                        HStack {
                            Text("Talkive is typing...")
                                .padding(10)
                                .background(typingIndicatorColor)
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var messageInputView: some View {
        HStack {
            TextField("Type a message...", text: $viewModel.currentMessage, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .padding(.vertical, 5)

            Button(action: {
                Task { await viewModel.sendMessage() }
                isTextFieldFocused = false
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(sendButtonColor)
            }
            .disabled(viewModel.currentMessage.isEmpty || viewModel.isLoading)

            Button(action: {
                showingTalkModeSheet = true
            }) {
                Image(systemName: "mic.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding(.leading, 5)
        }
        .sheet(isPresented: $showingTalkModeSheet) {
            TalkModeScreen()
                .environmentObject(viewModel)
        }
        .padding()
        .background(settingsViewModel.selectedTheme.inputBackgroundColor)
        .shadow(radius: 5)
    }


#Preview {
    ChatScreen()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(ChatViewModel()) // Ensure ChatViewModel is also provided as an environment object if needed by subviews
}
