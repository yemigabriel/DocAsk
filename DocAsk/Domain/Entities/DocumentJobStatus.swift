import Foundation

enum DocumentIngestionStatus: String, Equatable, Sendable {
    case uploaded
    case analyzing
    case ready
    case failed

    var displayText: String {
        switch self {
        case .uploaded:
            return "Uploaded document successfully"
        case .analyzing:
            return "Analysing document"
        case .ready:
            return "Document ready"
        case .failed:
            return "Failed"
        }
    }
}

struct DocumentJobStatus: Equatable, Sendable {
    let jobID: String
    let status: DocumentIngestionStatus
    let filename: String?
    let error: String?
}
