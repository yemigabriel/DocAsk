import Foundation

protocol DocumentRepository {
    func upload(document: PDFDocument) async throws -> DocumentUploadResult
}
