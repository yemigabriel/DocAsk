import Foundation

struct APIConfiguration {
    let baseURL: URL

    static let current = APIConfiguration(baseURL: resolvedBaseURL())

    var uploadURL: URL {
        baseURL.appending(path: "upload")
    }

    var askURL: URL {
        baseURL.appending(path: "ask")
    }

    private static func resolvedBaseURL() -> URL {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
            let url = URL(string: value)
        else {
            preconditionFailure("Missing or invalid APIBaseURL in Info.plist")
        }

        return url
    }
}
