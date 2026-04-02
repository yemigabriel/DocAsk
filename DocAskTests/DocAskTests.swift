import Foundation
import Testing
@testable import DocAsk

@MainActor
struct DocAskTests {
    @Test
    func uploadSuccessTransitionsToChat() async throws {
        let viewModel = DocAskViewModel(
            importDocumentUseCase: MockImportDocumentUseCase(document: PDFDocument(fileName: "brief.pdf", data: Data("pdf".utf8))),
            uploadDocumentUseCase: MockUploadDocumentUseCase(result: .success(
                DocumentUploadResult(jobID: "job-1", status: .uploaded, filename: "brief.pdf")
            )),
            getDocumentJobStatusUseCase: MockGetDocumentJobStatusUseCase(
                results: [
                    .success(DocumentJobStatus(jobID: "job-1", status: .analyzing, filename: "brief.pdf", error: nil)),
                    .success(DocumentJobStatus(jobID: "job-1", status: .ready, filename: "brief.pdf", error: nil))
                ]
            ),
            askQuestionUseCase: MockAskQuestionUseCase(
                result: .success(QuestionAnswer(question: "Q", answer: "A", context: [], history: [])),
                streamEvents: [.done(QuestionAnswer(question: "Q", answer: "A", context: [], history: []))]
            ),
            pollingInterval: .milliseconds(10)
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
            uploadDocumentUseCase: MockUploadDocumentUseCase(result: .success(
                DocumentUploadResult(jobID: "job-1", status: .uploaded, filename: "brief.pdf")
            )),
            getDocumentJobStatusUseCase: MockGetDocumentJobStatusUseCase(results: []),
            askQuestionUseCase: MockAskQuestionUseCase(result: .success(
                QuestionAnswer(
                    question: "What is this about?",
                    answer: "This document is about portfolio architecture.",
                    context: ["portfolio architecture"],
                    history: []
                )
            ), streamEvents: [
                .token("This document "),
                .token("is about portfolio architecture."),
                .done(
                    QuestionAnswer(
                        question: "What is this about?",
                        answer: "This document is about portfolio architecture.",
                        context: ["portfolio architecture"],
                        history: []
                    )
                )
            ])
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

private final class MockGetDocumentJobStatusUseCase: GetDocumentJobStatusUseCase {
    private var results: [Result<DocumentJobStatus, Error>]

    init(results: [Result<DocumentJobStatus, Error>]) {
        self.results = results
    }

    func execute(jobID: String) async throws -> DocumentJobStatus {
        guard !results.isEmpty else {
            return DocumentJobStatus(jobID: jobID, status: .ready, filename: nil, error: nil)
        }

        return try results.removeFirst().get()
    }
}

private struct MockAskQuestionUseCase: AskQuestionUseCase {
    let result: Result<QuestionAnswer, Error>
    let streamEvents: [StreamedQuestionAnswerEvent]

    init(result: Result<QuestionAnswer, Error>, streamEvents: [StreamedQuestionAnswerEvent] = []) {
        self.result = result
        self.streamEvents = streamEvents
    }

    func execute(question: String, history: [ConversationTurn]) async throws -> QuestionAnswer {
        try result.get()
    }

    func executeStream(question: String, history: [ConversationTurn]) -> AsyncThrowingStream<StreamedQuestionAnswerEvent, Error> {
        AsyncThrowingStream { continuation in
            for event in streamEvents {
                continuation.yield(event)
            }
            continuation.finish()
        }
    }
}
