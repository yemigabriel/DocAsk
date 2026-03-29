import Foundation

protocol UploadDocumentUseCase {
    func execute(document: PDFDocument) async throws -> DocumentUploadResult
}

struct DefaultUploadDocumentUseCase: UploadDocumentUseCase {
    private let repository: any DocumentRepository

    init(repository: any DocumentRepository) {
        self.repository = repository
    }

    func execute(document: PDFDocument) async throws -> DocumentUploadResult {
        try await repository.upload(document: document)
    }
}
