import Foundation

struct DocumentUploadResult: Equatable, Sendable {
    let jobID: String
    let status: DocumentIngestionStatus
    let filename: String
}
