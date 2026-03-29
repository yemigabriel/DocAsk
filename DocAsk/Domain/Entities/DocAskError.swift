import Foundation

enum DocAskError: LocalizedError, Equatable {
    case invalidDocument
    case documentReadFailed
    case invalidServerResponse
    case serverFailure(statusCode: Int, message: String)
    case decodingFailure
    case transportFailure(String)

    var errorDescription: String? {
        switch self {
        case .invalidDocument:
            return "The selected file is not a valid PDF."
        case .documentReadFailed:
            return "The selected PDF could not be read."
        case .invalidServerResponse:
            return "The server returned an invalid response."
        case .serverFailure(let statusCode, let message):
            if message.isEmpty {
                return "The server returned status \(statusCode)."
            }

            return "The server returned status \(statusCode): \(message)"
        case .decodingFailure:
            return "The app could not decode the server response."
        case .transportFailure(let message):
            return message
        }
    }
}
