import Foundation

enum ProgressStep: CaseIterable {
    case uploading
    case analyzing
    case ready

    var title: String {
        switch self {
        case .uploading:
            return "Uploading document"
        case .analyzing:
            return "Analyzing document"
        case .ready:
            return "Ready to ask questions"
        }
    }

    var detail: String {
        switch self {
        case .uploading:
            return "Sending the PDF to the backend."
        case .analyzing:
            return "Waiting for ingestion and indexing to finish."
        case .ready:
            return "Document processing is complete."
        }
    }
}
