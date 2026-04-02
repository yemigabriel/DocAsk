import Foundation

protocol DocumentRepository {
    func upload(document: PDFDocument) async throws -> DocumentUploadResult
    func getJobStatus(jobID: String) async throws -> DocumentJobStatus
}
