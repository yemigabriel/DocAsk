import Foundation

struct LocalPDFDocumentLoader: DocumentImporting {
    func loadDocument(from fileURL: URL) throws -> PDFDocument {
        let didAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        guard fileURL.pathExtension.lowercased() == "pdf" else {
            throw DocAskError.invalidDocument
        }

        do {
            return PDFDocument(
                fileName: fileURL.lastPathComponent,
                data: try Data(contentsOf: fileURL)
            )
        } catch {
            throw DocAskError.documentReadFailed
        }
    }
}
