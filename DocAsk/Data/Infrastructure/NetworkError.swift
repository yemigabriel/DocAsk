import Foundation

enum DataLayerError: LocalizedError, Equatable {
    case invalidPDF
    case unreadableFile
    case invalidResponse
    case serverError(Int, String)
    case decodingFailed
    case transportError(String)

    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "The selected file is not a valid PDF."
        case .unreadableFile:
            return "The selected PDF could not be read."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .serverError(let statusCode, let message):
            if message.isEmpty {
                return "The server returned status \(statusCode)."
            }

            return "The server returned status \(statusCode): \(message)"
        case .decodingFailed:
            return "The app could not decode the server response."
        case .transportError(let message):
            return message
        }
    }
}
