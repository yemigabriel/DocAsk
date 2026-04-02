import Foundation

struct RemoteDocumentRepository: DocumentRepository {
    private let session: URLSession
    private let configuration: APIConfiguration

    init(
        session: URLSession = .shared,
        configuration: APIConfiguration = .current
    ) {
        self.session = session
        self.configuration = configuration
    }

    func upload(document: PDFDocument) async throws -> DocumentUploadResult {
        var request = URLRequest(url: configuration.uploadURL)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = MultipartFormDataBuilder.makePDFBody(
            boundary: boundary,
            fileName: document.fileName,
            fileData: document.data
        )

        do {
            let (data, response) = try await session.upload(for: request, from: body)
            _ = try HTTPResponseValidator.validate(response: response, data: data)

            do {
                let dto = try JSONDecoder().decode(UploadResponseDTO.self, from: data)
                return dto.toDomain()
            } catch {
                throw DataLayerError.decodingFailed
            }
        } catch let error as DataLayerError {
            throw map(error)
        } catch {
            throw DocAskError.transportFailure(error.localizedDescription)
        }
    }

    func getJobStatus(jobID: String) async throws -> DocumentJobStatus {
        let request = URLRequest(url: configuration.jobStatusURL(jobID: jobID))

        do {
            let (data, response) = try await session.data(for: request)
            _ = try HTTPResponseValidator.validate(response: response, data: data)

            do {
                let dto = try JSONDecoder().decode(JobStatusResponseDTO.self, from: data)
                return dto.toDomain()
            } catch {
                throw DataLayerError.decodingFailed
            }
        } catch let error as DataLayerError {
            throw map(error)
        } catch {
            throw DocAskError.transportFailure(error.localizedDescription)
        }
    }

    private func map(_ error: DataLayerError) -> DocAskError {
        switch error {
        case .invalidPDF:
            return .invalidDocument
        case .unreadableFile:
            return .documentReadFailed
        case .invalidResponse:
            return .invalidServerResponse
        case .serverError(let statusCode, let message):
            return .serverFailure(statusCode: statusCode, message: message)
        case .decodingFailed:
            return .decodingFailure
        case .transportError(let message):
            return .transportFailure(message)
        }
    }
}
