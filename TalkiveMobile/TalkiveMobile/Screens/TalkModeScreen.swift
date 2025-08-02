import SwiftUI

struct TalkModeScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 200, height: 200)

                Image("AppIcon") // Geçici olarak AppIcon kullanıyoruz
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }
            .padding(.bottom, 50)

            Text(chatViewModel.voiceAssistant.isRecording ? "Listening..." : "Tap to speak")
                .font(.title2)
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                if chatViewModel.voiceAssistant.isRecording {
                    chatViewModel.voiceAssistant.stopRecording()
                    Task { await chatViewModel.sendVoiceMessage(transcribedText: chatViewModel.voiceAssistant.transcribedText) }
                    dismiss()
                } else {
                    do {
                        try chatViewModel.voiceAssistant.startRecording()
                    } catch {
                        print("Error starting recording: \(error.localizedDescription)")
                        // TODO: Show alert to user about microphone permission
                    }
                }
            }) {
                Image(systemName: chatViewModel.voiceAssistant.isRecording ? "mic.fill" : "mic.circle")
                    .font(.largeTitle)
                    .foregroundColor(chatViewModel.voiceAssistant.isRecording ? .red : .blue)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            // Start recording automatically when the screen appears
            do {
                try chatViewModel.voiceAssistant.startRecording()
            } catch {
                print("Error starting recording: \(error.localizedDescription)")
                // TODO: Show alert to user about microphone permission
            }
        }
        .onDisappear {
            // Stop recording when the screen disappears
            chatViewModel.voiceAssistant.stopRecording()
        }
    }
}

#Preview {
    TalkModeScreen()
        .environmentObject(ChatViewModel())
}