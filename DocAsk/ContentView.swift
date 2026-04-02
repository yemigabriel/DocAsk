//
//  ContentView.swift
//  DocAsk
//
//  Created by Yemi Gabriel on 27/03/2026.
//

import Observation
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var viewModel: DocAskViewModel

    init(viewModel: DocAskViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                switch viewModel.currentScreen {
                case .welcome:
                    WelcomeScreenView(
                        onUploadTapped: viewModel.presentFileImporter
                    )
                case .progress:
                    ProcessingScreenView(
                        selectedFileName: viewModel.selectedFileName,
                        uploadStatusMessage: viewModel.uploadStatusMessage,
                        progressStepIndex: viewModel.progressStepIndex,
                        onCancelTapped: viewModel.cancelUpload
                    )
                case .chat:
                    ChatScreenView(
                        messages: viewModel.messages,
                        draftQuestion: $viewModel.draftQuestion,
                        isAnswering: viewModel.isAnswering,
                        onSendTapped: viewModel.submitQuestion,
                        onStartOverTapped: viewModel.resetFlow
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.currentScreen == .chat {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("New Document") {
                            viewModel.resetFlow()
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $viewModel.isShowingFileImporter,
            allowedContentTypes: [.pdf]
        ) { result in
            viewModel.handleFileImport(result)
        }
        .alert(item: $viewModel.alertState) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onDisappear {
            viewModel.cancelAllTasks()
        }
    }
}

#Preview {
    ContentView(viewModel: AppContainer().makeDocAskViewModel())
}
