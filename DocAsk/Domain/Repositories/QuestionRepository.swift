import Foundation

protocol QuestionRepository {
    func ask(question: String, history: [ConversationTurn], topK: Int) async throws -> QuestionAnswer
}
