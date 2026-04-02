import SwiftUI

struct ProcessingScreenView: View {
    let selectedFileName: String
    let uploadStatusMessage: String
    let progressStepIndex: Int
    let onCancelTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Preparing your document")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("DocAsk is uploading and processing the PDF on the backend.")
                    .foregroundStyle(.secondary)

                if !selectedFileName.isEmpty {
                    Label(selectedFileName, systemImage: "doc.richtext")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(ProgressStep.allCases.enumerated()), id: \.offset) { index, step in
                    timelineRow(for: step, index: index)
                }
            }

            Button("Cancel", role: .cancel, action: onCancelTapped)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .animation(.smooth, value: progressStepIndex)
    }

    private func timelineRow(for step: ProgressStep, index: Int) -> some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 0) {
                stepMarker(for: index)

                if index < ProgressStep.allCases.count - 1 {
                    Rectangle()
                        .fill(connectorColor(for: index))
                        .frame(width: 3)
                        .frame(height: 72)
                        .padding(.vertical, 8)
                }
            }
            .frame(width: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(titleColor(for: index))

                Text(detailText(for: step, index: index))
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(detailColor(for: index))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowFill(for: index), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(rowStroke(for: index), lineWidth: index == progressStepIndex ? 1.2 : 0)
            }
        }
        .frame(minHeight: 112, alignment: .top)
    }

    private func detailText(for step: ProgressStep, index: Int) -> String {
        if index == progressStepIndex {
            return uploadStatusMessage
        }

        return step.detail
    }

    private func stepMarker(for index: Int) -> some View {
        ZStack {
            if index == progressStepIndex {
                Circle()
                    .stroke(Color.accentColor.opacity(0.24), lineWidth: 7)
                    .frame(width: 42, height: 42)
            }

            Circle()
                .fill(nodeFillColor(for: index))
                .frame(width: 30, height: 30)

            Circle()
                .fill(nodeInnerColor(for: index))
                .frame(width: 10, height: 10)
        }
        .frame(width: 42, height: 42)
    }

    private func nodeFillColor(for index: Int) -> Color {
        if index <= progressStepIndex {
            return .accentColor
        } else {
            return Color(.systemBackground)
        }
    }

    private func nodeInnerColor(for index: Int) -> Color {
        if index <= progressStepIndex {
            return .white
        } else {
            return Color.secondary.opacity(0.18)
        }
    }

    private func connectorColor(for index: Int) -> Color {
        if index < progressStepIndex {
            return .accentColor
        } else {
            return Color.secondary.opacity(0.15)
        }
    }

    private func rowFill(for index: Int) -> Color {
        if index == progressStepIndex {
            return Color(.systemBackground)
        } else {
            return .clear
        }
    }

    private func rowStroke(for index: Int) -> Color {
        Color.secondary.opacity(0.12)
    }

    private func titleColor(for index: Int) -> Color {
        if index > progressStepIndex {
            return Color.primary.opacity(0.28)
        } else {
            return .primary
        }
    }

    private func detailColor(for index: Int) -> Color {
        if index > progressStepIndex {
            return Color.secondary.opacity(0.35)
        } else {
            return .secondary
        }
    }
}
