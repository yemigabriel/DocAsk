import Foundation

protocol AskQuestionUseCase {
    func execute(question: String, history: [ConversationTurn]) async throws -> QuestionAnswer
    func executeStream(question: String, history: [ConversationTurn]) -> AsyncThrowingStream<StreamedQuestionAnswerEvent, Error>
}

struct DefaultAskQuestionUseCase: AskQuestionUseCase {
    private let repository: any QuestionRepository
    private let topK: Int

    init(repository: any QuestionRepository, topK: Int = 5) {
        self.repository = repository
        self.topK = topK
    }

    func execute(question: String, history: [ConversationTurn]) async throws -> QuestionAnswer {
        try await repository.ask(question: question, history: history, topK: topK)
    }

    func executeStream(question: String, history: [ConversationTurn]) -> AsyncThrowingStream<StreamedQuestionAnswerEvent, Error> {
        repository.streamAnswer(question: question, history: history, topK: topK)
    }
}
