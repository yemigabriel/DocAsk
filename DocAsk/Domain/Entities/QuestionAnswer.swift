import Foundation

struct QuestionAnswer: Equatable, Sendable {
    let question: String
    let answer: String
    let context: [String]
    let history: [ConversationTurn]
}

enum StreamedQuestionAnswerEvent: Equatable, Sendable {
    case token(String)
    case done(QuestionAnswer)
}
