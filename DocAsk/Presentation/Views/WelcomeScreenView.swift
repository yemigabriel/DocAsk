import SwiftUI

struct WelcomeScreenView: View {
    let onUploadTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text(styledTitle)
                .font(.system(size: 40, weight: .bold, design: .rounded))

                Text("Upload a PDF, let the backend index it, then ask focused questions with a clean chat experience.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                Label("Select a PDF from Files", systemImage: "doc.text")
                Label("Send it to the RAG backend", systemImage: "arrow.up.doc")
                Label("Chat against indexed context", systemImage: "message")
            }
            .font(.headline)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 12) {
                Button(action: onUploadTapped) {
                    Label("Upload PDF", systemImage: "arrow.up.doc.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()
        }
        .padding(24)
    }

    private var styledTitle: AttributedString {
        var title = AttributedString("DocAsk")

        if let range = title.range(of: "Ask") {
            title[range].foregroundColor = .blue
            title[range].underlineStyle = .single
        }

        return title
    }
}
