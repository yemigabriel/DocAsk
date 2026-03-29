import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String

    init(id: UUID = UUID(), role: ChatRole, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

enum ChatRole: String, Codable {
    case user
    case assistant

    var title: String {
        switch self {
        case .user:
            return "You"
        case .assistant:
            return "DocAsk"
        }
    }
}

struct ConversationTurn: Codable, Equatable {
    let role: ChatRole
    let content: String
}

extension ChatMessage {
    var conversationTurn: ConversationTurn {
        ConversationTurn(role: role, content: text)
    }
}
