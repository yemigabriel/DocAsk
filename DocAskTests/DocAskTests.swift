import Foundation
import Testing
@testable import DocAsk

@MainActor
struct DocAskTests {
    @Test
    func uploadSuccessTransitionsToChat() async throws {
        let viewModel = DocAskViewModel(
            importDocumentUseCase: MockImportDocumentUseCase(document: PDFDocument(fileName: "brief.pdf", data: Data("pdf".utf8))),
            uploadDocumentUseCase: MockUploadDocumentUseCase(result: .success(DocumentUploadResult(message: "PDF ingested successfully."))),
            askQuestionUseCase: MockAskQuestionUseCase(result: .success(QuestionAnswer(question: "Q", answer: "A", context: [], history: [])))
        )

        viewModel.startUpload(for: PDFDocument(fileName: "brief.pdf", data: Data("pdf".utf8)))
        try await Task.sleep(for: .seconds(0.8))

        #expect(viewModel.currentScreen == .chat)
        #expect(viewModel.progressStepIndex == 2)
        #expect(viewModel.messages.last?.text.contains("brief.pdf") == true)
    }

    @Test
    func submitQuestionAppendsBackendAnswer() async throws {
        let viewModel = DocAskViewModel(
            importDocumentUseCase: MockImportDocumentUseCase(document: PDFDocument(fileName: "brief.pdf", data: Data("pdf".utf8))),
            uploadDocumentUseCase: MockUploadDocumentUseCase(result: .success(DocumentUploadResult(message: "PDF ingested successfully."))),
            askQuestionUseCase: MockAskQuestionUseCase(result: .success(
                QuestionAnswer(
                    question: "What is this about?",
                    answer: "This document is about portfolio architecture.",
                    context: ["portfolio architecture"],
                    history: []
                )
            ))
        )

        viewModel.currentScreen = .chat
        viewModel.draftQuestion = "What is this about?"
        viewModel.submitQuestion()
        try await Task.sleep(for: .seconds(0.1))

        #expect(viewModel.messages.last?.text == "This document is about portfolio architecture.")
        #expect(viewModel.isAnswering == false)
    }
}

private struct MockImportDocumentUseCase: ImportDocumentUseCase {
    let document: PDFDocument

    func execute(fileURL: URL) throws -> PDFDocument {
        document
    }
}

private struct MockUploadDocumentUseCase: UploadDocumentUseCase {
    let result: Result<DocumentUploadResult, Error>

    func execute(document: PDFDocument) async throws -> DocumentUploadResult {
        try result.get()
    }
}

private struct MockAskQuestionUseCase: AskQuestionUseCase {
    let result: Result<QuestionAnswer, Error>

    func execute(question: String, history: [ConversationTurn]) async throws -> QuestionAnswer {
        try result.get()
    }
}
