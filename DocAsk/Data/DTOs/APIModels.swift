import Foundation

struct UploadResponseDTO: Decodable, Equatable {
    let jobID: String
    let status: JobStatusDTO
    let filename: String

    enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case status
        case filename
    }

    func toDomain() -> DocumentUploadResult {
        DocumentUploadResult(jobID: jobID, status: status.toDomain(), filename: filename)
    }
}

struct JobStatusResponseDTO: Decodable, Equatable {
    let jobID: String
    let status: JobStatusDTO
    let filename: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case status
        case filename
        case error
    }

    func toDomain() -> DocumentJobStatus {
        DocumentJobStatus(
            jobID: jobID,
            status: status.toDomain(),
            filename: filename,
            error: error
        )
    }
}

enum JobStatusDTO: String, Decodable, Equatable {
    case uploaded = "Uploaded document successfully"
    case analyzing = "Analysing document"
    case ready = "Document ready"
    case failed = "Failed"

    func toDomain() -> DocumentIngestionStatus {
        switch self {
        case .uploaded:
            return .uploaded
        case .analyzing:
            return .analyzing
        case .ready:
            return .ready
        case .failed:
            return .failed
        }
    }
}

struct AskRequestDTO: Encodable {
    let question: String
    let topK: Int
    let history: [[String: String]]

    enum CodingKeys: String, CodingKey {
        case question
        case topK = "top_k"
        case history
    }
}

struct AskResponseDTO: Decodable, Equatable {
    let question: String
    let answer: String
    let context: [String]
    let history: [[String: String]]

    func toDomain() -> QuestionAnswer {
        QuestionAnswer(
            question: question,
            answer: answer,
            context: context,
            history: history.compactMap { item in
                guard
                    let roleValue = item["role"],
                    let role = ChatRole(rawValue: roleValue),
                    let content = item["content"]
                else {
                    return nil
                }

                return ConversationTurn(role: role, content: content)
            }
        )
    }
}

struct StreamEventDTO: Decodable {
    let type: String
    let content: String?
    let payload: AskResponseDTO?
}
