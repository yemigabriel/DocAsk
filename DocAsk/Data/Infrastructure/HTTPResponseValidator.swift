import Foundation

enum HTTPResponseValidator {
    @discardableResult
    static func validate(response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataLayerError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? ""
            throw DataLayerError.serverError(httpResponse.statusCode, message)
        }

        return httpResponse
    }
}
