import Foundation

struct QuestionAnswer: Equatable, Sendable {
    let question: String
    let answer: String
    let context: [String]
    let history: [ConversationTurn]
}
