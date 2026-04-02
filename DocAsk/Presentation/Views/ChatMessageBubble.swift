import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble(alignment: .leading, tint: Color.blue.opacity(0.12))
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble(alignment: .trailing, tint: Color.accentColor.opacity(0.18))
            }
        }
    }

    private func bubble(alignment: HorizontalAlignment, tint: Color) -> some View {
        VStack(alignment: alignment, spacing: 6) {
            Text(message.role.title)
                .font(.caption)
                .foregroundStyle(.secondary)

            messageBody(alignment: alignment)
                .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
        }
        .padding(16)
        .background(tint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func messageBody(alignment: HorizontalAlignment) -> some View {
        if message.role == .assistant, let markdown = try? AttributedString(
            markdown: message.text,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            Text(markdown)
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
        } else {
            Text(message.text)
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
        }
    }
}
