import SwiftUI

struct ProcessingScreenView: View {
    let progressMode: ProgressMode
    let selectedFileName: String
    let uploadStatusMessage: String
    let progressStepIndex: Int
    let onCancelTapped: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Preparing your document")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("DocAsk is uploading and processing the PDF on the backend.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if !selectedFileName.isEmpty {
                    Label(selectedFileName, systemImage: "doc.richtext")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if progressMode == .steps {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(ProgressStep.allCases.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            Image(systemName: iconName(for: index))
                                .foregroundStyle(iconColor(for: index))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.headline)
                                Text(detailText(for: step, index: index))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(backgroundColor(for: index), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                        .scaleEffect(1.5)

                    Text(progressSummaryText)
                        .font(.headline)

                    Text(uploadStatusMessage)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            Button("Cancel Upload", role: .cancel, action: onCancelTapped)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .animation(.smooth, value: progressStepIndex)
    }

    private var progressSummaryText: String {
        switch progressStepIndex {
        case 0:
            return "Uploading document..."
        case 1:
            return "Analyzing document..."
        case 2:
            return "Ready to ask questions."
        default:
            return "Waiting to start..."
        }
    }

    private func detailText(for step: ProgressStep, index: Int) -> String {
        if index == progressStepIndex {
            return uploadStatusMessage
        }

        return step.detail
    }

    private func iconName(for index: Int) -> String {
        if index < progressStepIndex {
            return "checkmark.circle.fill"
        } else if index == progressStepIndex {
            return "clock.badge.checkmark.fill"
        } else {
            return "circle"
        }
    }

    private func iconColor(for index: Int) -> Color {
        if index < progressStepIndex {
            return .green
        } else if index == progressStepIndex {
            return .accentColor
        } else {
            return .secondary
        }
    }

    private func backgroundColor(for index: Int) -> Color {
        if index < progressStepIndex {
            return Color.green.opacity(0.12)
        } else if index == progressStepIndex {
            return Color.accentColor.opacity(0.12)
        } else {
            return Color.secondary.opacity(0.08)
        }
    }
}
