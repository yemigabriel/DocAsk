import Foundation

protocol QuestionRepository {
    func ask(question: String, history: [ConversationTurn], topK: Int) async throws -> QuestionAnswer
    func streamAnswer(question: String, history: [ConversationTurn], topK: Int) -> AsyncThrowingStream<StreamedQuestionAnswerEvent, Error>
}
