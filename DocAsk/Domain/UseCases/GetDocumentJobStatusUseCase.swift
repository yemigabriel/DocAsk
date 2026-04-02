import Foundation

protocol GetDocumentJobStatusUseCase {
    func execute(jobID: String) async throws -> DocumentJobStatus
}

struct DefaultGetDocumentJobStatusUseCase: GetDocumentJobStatusUseCase {
    private let repository: any DocumentRepository

    init(repository: any DocumentRepository) {
        self.repository = repository
    }

    func execute(jobID: String) async throws -> DocumentJobStatus {
        try await repository.getJobStatus(jobID: jobID)
    }
}
