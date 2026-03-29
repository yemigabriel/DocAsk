import Foundation

struct RemoteQuestionRepository: QuestionRepository {
    private let session: URLSession
    private let configuration: APIConfiguration

    init(
        session: URLSession = .shared,
        configuration: APIConfiguration = .current
    ) {
        self.session = session
        self.configuration = configuration
    }

    func ask(question: String, history: [ConversationTurn], topK: Int) async throws -> QuestionAnswer {
        var request = URLRequest(url: configuration.askURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let payload = AskRequestDTO(
            question: question,
            topK: topK,
            history: history.map { ["role": $0.role.rawValue, "content": $0.content] }
        )
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await session.data(for: request)
            _ = try HTTPResponseValidator.validate(response: response, data: data)

            do {
                let dto = try JSONDecoder().decode(AskResponseDTO.self, from: data)
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
