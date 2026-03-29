import SwiftUI

struct ChatScreenView: View {
    let messages: [ChatMessage]
    @Binding var draftQuestion: String
    let isAnswering: Bool
    let onSendTapped: () -> Void
    let onStartOverTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageBubble(message: message)
                    }

                    if isAnswering {
                        HStack {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Generating answer...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(.regularMaterial, in: Capsule())

                            Spacer()
                        }
                    }
                }
                .padding(24)
            }

            VStack(spacing: 12) {
                TextField("Ask a question about the document", text: $draftQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                HStack(spacing: 12) {
                    Button("Start Over", action: onStartOverTapped)
                        .buttonStyle(.bordered)

                    Button(action: onSendTapped) {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draftQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnswering)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
        }
    }
}
