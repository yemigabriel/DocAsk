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

    func streamAnswer(question: String, history: [ConversationTurn], topK: Int) -> AsyncThrowingStream<StreamedQuestionAnswerEvent, Error> {
        AsyncThrowingStream { continuation in
            let payload = AskRequestDTO(
                question: question,
                topK: topK,
                history: history.map { ["role": $0.role.rawValue, "content": $0.content] }
            )

            let task = Task {
                do {
                    var request = URLRequest(url: configuration.askStreamURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.httpBody = try JSONEncoder().encode(payload)

                    let (bytes, response) = try await session.bytes(for: request)
                    _ = try HTTPResponseValidator.validate(response: response, data: Data())

                    for try await line in bytes.lines {
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("data:") else { continue }

                        let rawJSON = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        guard !rawJSON.isEmpty else { continue }

                        let event = try decodeStreamEvent(from: rawJSON)
                        switch event.type {
                        case "token":
                            if let content = event.content {
                                continuation.yield(.token(content))
                            }
                        case "done":
                            if let payload = event.payload {
                                continuation.yield(.done(payload.toDomain()))
                                continuation.finish()
                                return
                            }
                        case "error":
                            let message = event.content ?? "Streaming response failed."
                            continuation.finish(throwing: DocAskError.transportFailure(message))
                            return
                        default:
                            continue
                        }
                    }

                    continuation.finish(throwing: DocAskError.transportFailure("Streaming response ended unexpectedly."))
                } catch let error as DataLayerError {
                    continuation.finish(throwing: map(error))
                } catch let error as DocAskError {
                    continuation.finish(throwing: error)
                } catch {
                    continuation.finish(throwing: DocAskError.transportFailure(error.localizedDescription))
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func decodeStreamEvent(from rawJSON: String) throws -> StreamEventDTO {
        guard let data = rawJSON.data(using: .utf8) else {
            throw DataLayerError.decodingFailed
        }

        do {
            return try JSONDecoder().decode(StreamEventDTO.self, from: data)
        } catch {
            throw DataLayerError.decodingFailed
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
