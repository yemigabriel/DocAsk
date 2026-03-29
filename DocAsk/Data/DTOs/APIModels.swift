import Foundation

struct UploadResponseDTO: Decodable, Equatable {
    let message: String

    func toDomain() -> DocumentUploadResult {
        DocumentUploadResult(message: message)
    }
}

struct AskRequestDTO: Encodable {
    let question: String
    let topK: Int
    let history: [[String: String]]

    enum CodingKeys: String, CodingKey {
        case question
        case topK = "top_k"
        case history
    }
}

struct AskResponseDTO: Decodable, Equatable {
    let question: String
    let answer: String
    let context: [String]
    let history: [[String: String]]

    func toDomain() -> QuestionAnswer {
        QuestionAnswer(
            question: question,
            answer: answer,
            context: context,
            history: history.compactMap { item in
                guard
                    let roleValue = item["role"],
                    let role = ChatRole(rawValue: roleValue),
                    let content = item["content"]
                else {
                    return nil
                }

                return ConversationTurn(role: role, content: content)
            }
        )
    }
}
