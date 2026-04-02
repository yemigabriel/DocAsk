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

    var askStreamURL: URL {
        baseURL.appending(path: "ask").appending(path: "stream")
    }

    func jobStatusURL(jobID: String) -> URL {
        baseURL.appending(path: "jobs").appending(path: jobID)
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
