import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class DocAskViewModel {
    var currentScreen: AppScreen = .welcome
    var progressStepIndex = 0
    var isShowingFileImporter = false
    var selectedFileName = ""
    var uploadStatusMessage = "Select a PDF to begin."
    var alertState: AlertState?
    var messages: [ChatMessage] = [ChatMessage(role: .assistant, text: "Your document is ready. Ask a question to get started.")]
    var draftQuestion = ""
    var isAnswering = false

    private let importDocumentUseCase: ImportDocumentUseCase
    private let uploadDocumentUseCase: UploadDocumentUseCase
    private let getDocumentJobStatusUseCase: GetDocumentJobStatusUseCase
    private let askQuestionUseCase: AskQuestionUseCase
    private let pollingInterval: Duration

    private var uploadTask: Task<Void, Never>?
    private var chatTask: Task<Void, Never>?

    init(
        importDocumentUseCase: ImportDocumentUseCase,
        uploadDocumentUseCase: UploadDocumentUseCase,
        getDocumentJobStatusUseCase: GetDocumentJobStatusUseCase,
        askQuestionUseCase: AskQuestionUseCase,
        pollingInterval: Duration = .seconds(2)
    ) {
        self.importDocumentUseCase = importDocumentUseCase
        self.uploadDocumentUseCase = uploadDocumentUseCase
        self.getDocumentJobStatusUseCase = getDocumentJobStatusUseCase
        self.askQuestionUseCase = askQuestionUseCase
        self.pollingInterval = pollingInterval
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
        let assistantMessageID = UUID()
        messages.append(ChatMessage(id: assistantMessageID, role: .assistant, text: ""))
        draftQuestion = ""
        isAnswering = true

        let history = messages.map(\.conversationTurn)
        chatTask = Task {
            do {
                try await runQuestionSubmission(
                    question: question,
                    history: history,
                    assistantMessageID: assistantMessageID
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

        selectedFileName = response.filename
        applyProgress(status: response.status, fallbackMessage: "Upload complete. Background ingestion started.")

        while true {
            try await Task.sleep(for: pollingInterval)
            try Task.checkCancellation()

            let jobStatus = try await getDocumentJobStatusUseCase.execute(jobID: response.jobID)
            try Task.checkCancellation()
            if try handle(jobStatus: jobStatus, document: document) {
                return
            }
        }
    }

    private func runQuestionSubmission(
        question: String,
        history: [ConversationTurn],
        assistantMessageID: UUID
    ) async throws {
        var finalResponse: QuestionAnswer?

        for try await event in askQuestionUseCase.executeStream(question: question, history: history) {
            try Task.checkCancellation()

            switch event {
            case .token(let token):
                appendToken(token, to: assistantMessageID)
            case .done(let response):
                finalResponse = response
                replaceMessage(id: assistantMessageID, text: response.answer)
            }
        }

        try Task.checkCancellation()

        if let finalResponse {
            replaceMessage(id: assistantMessageID, text: finalResponse.answer)
        }

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

    private func handle(jobStatus: DocumentJobStatus, document: PDFDocument) throws -> Bool {
        selectedFileName = jobStatus.filename ?? document.fileName
        applyProgress(status: jobStatus.status, fallbackMessage: jobStatus.error)

        switch jobStatus.status {
        case .uploaded, .analyzing:
            return false
        case .ready:
            messages = [
                ChatMessage(role: .assistant, text: "\(document.fileName) was ingested successfully. Ask a question to get started.")
            ]
            currentScreen = .chat
            return true
        case .failed:
            throw DocAskError.ingestionFailed(jobStatus.error ?? "Document ingestion failed.")
        }
    }

    private func applyProgress(status: DocumentIngestionStatus, fallbackMessage: String?) {
        switch status {
        case .uploaded:
            progressStepIndex = 0
            uploadStatusMessage = fallbackMessage ?? "Uploaded document successfully"
        case .analyzing:
            progressStepIndex = 1
            uploadStatusMessage = fallbackMessage ?? "Analysing document"
        case .ready:
            progressStepIndex = 2
            uploadStatusMessage = fallbackMessage ?? "Document ready"
        case .failed:
            progressStepIndex = 1
            uploadStatusMessage = fallbackMessage ?? "Ingestion failed"
        }
    }

    private func appendToken(_ token: String, to messageID: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        let current = messages[index]
        messages[index] = ChatMessage(id: current.id, role: current.role, text: current.text + token)
    }

    private func replaceMessage(id: UUID, text: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        let current = messages[index]
        messages[index] = ChatMessage(id: current.id, role: current.role, text: text)
    }
}
