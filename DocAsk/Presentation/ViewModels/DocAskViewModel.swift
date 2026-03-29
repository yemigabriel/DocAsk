import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class DocAskViewModel {
    var currentScreen: AppScreen = .welcome
    var progressMode: ProgressMode = .steps
    var progressStepIndex = 0
    var isShowingFileImporter = false
    var selectedFileName = ""
    var uploadStatusMessage = "Select a PDF to begin."
    var alertState: AlertState?
    var messages: [ChatMessage] = [ChatMessage(role: .assistant, text: "Your document is ready. Ask a question to get started.")]
    var draftQuestion = ""
    var isAnswering = false

    private let importDocumentUseCase: any ImportDocumentUseCase
    private let uploadDocumentUseCase: any UploadDocumentUseCase
    private let askQuestionUseCase: any AskQuestionUseCase

    private var uploadTask: Task<Void, Never>?
    private var chatTask: Task<Void, Never>?

    init(
        importDocumentUseCase: any ImportDocumentUseCase,
        uploadDocumentUseCase: any UploadDocumentUseCase,
        askQuestionUseCase: any AskQuestionUseCase
    ) {
        self.importDocumentUseCase = importDocumentUseCase
        self.uploadDocumentUseCase = uploadDocumentUseCase
        self.askQuestionUseCase = askQuestionUseCase
    }

    func presentFileImporter() {
        isShowingFileImporter = true
    }

    func handleFileImport(_ result: Result<URL, Error>) {
        do {
            let fileURL = try result.get()
            let document = try importDocumentUseCase.execute(fileURL: fileURL)
            startUpload(for: document)
        } catch let error as DocAskError {
            showError(error)
        } catch {
            alertState = AlertState(title: "Upload Error", message: error.localizedDescription)
        }
    }

    func startUpload(for document: PDFDocument) {
        cancelAllTasks()

        selectedFileName = document.fileName
        progressStepIndex = 0
        uploadStatusMessage = "Uploading \(document.fileName)..."
        currentScreen = .progress

        uploadTask = Task {
            do {
                try await runUpload(for: document)
            } catch is CancellationError {
                resetFlow()
            } catch let error as DocAskError {
                resetFlow()
                showError(error)
            } catch {
                resetFlow()
                alertState = AlertState(title: "Upload Error", message: error.localizedDescription)
            }
        }
    }

    func cancelUpload() {
        uploadTask?.cancel()
        resetFlow()
    }

    func submitQuestion() {
        let question = draftQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isAnswering else { return }

        chatTask?.cancel()

        messages.append(ChatMessage(role: .user, text: question))
        draftQuestion = ""
        isAnswering = true

        let history = messages.map(\.conversationTurn)

        chatTask = Task {
            do {
                try await runQuestionSubmission(
                    question: question,
                    history: history
                )
            } catch is CancellationError {
                isAnswering = false
            } catch let error as DocAskError {
                isAnswering = false
                messages.removeLast()
                showError(error)
            } catch {
                isAnswering = false
                messages.removeLast()
                alertState = AlertState(title: "Question Error", message: error.localizedDescription)
            }
        }
    }

    func resetFlow() {
        cancelAllTasks()
        currentScreen = .welcome
        progressStepIndex = 0
        isShowingFileImporter = false
        selectedFileName = ""
        uploadStatusMessage = "Select a PDF to begin."
        draftQuestion = ""
        isAnswering = false
        messages = [ChatMessage(role: .assistant, text: "Your document is ready. Ask a question to get started.")]
    }

    func cancelAllTasks() {
        uploadTask?.cancel()
        chatTask?.cancel()
        uploadTask = nil
        chatTask = nil
    }

    private func runUpload(for document: PDFDocument) async throws {
        let response = try await uploadDocumentUseCase.execute(document: document)
        try Task.checkCancellation()

        progressStepIndex = 1
        uploadStatusMessage = response.message
        try await Task.sleep(for: .seconds(0.35))

        progressStepIndex = 2
        uploadStatusMessage = "Document ready. Start asking questions."
        messages = [
            ChatMessage(role: .assistant, text: "\(document.fileName) was ingested successfully. Ask a question to get started.")
        ]

        try await Task.sleep(for: .seconds(0.25))
        currentScreen = .chat
    }

    private func runQuestionSubmission(question: String, history: [ConversationTurn]) async throws {
        let response = try await askQuestionUseCase.execute(question: question, history: history)

        try Task.checkCancellation()
        messages.append(ChatMessage(role: .assistant, text: response.answer))
        isAnswering = false
    }

    private func showError(_ error: DocAskError) {
        let title: String
        switch currentScreen {
        case .chat:
            title = "Question Error"
        case .welcome, .progress:
            title = "Upload Error"
        }

        alertState = AlertState(title: title, message: error.errorDescription ?? "Something went wrong.")
    }
}
