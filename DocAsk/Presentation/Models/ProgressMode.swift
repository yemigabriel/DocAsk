import Foundation

enum ProgressMode: String, CaseIterable, Identifiable {
    case steps
    case spinner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .steps:
            return "Step Status"
        case .spinner:
            return "Spinner"
        }
    }
}
