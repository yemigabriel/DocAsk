import Foundation

protocol ImportDocumentUseCase {
    func execute(fileURL: URL) throws -> PDFDocument
}

struct DefaultImportDocumentUseCase: ImportDocumentUseCase {
    private let documentImporter: any DocumentImporting

    init(documentImporter: any DocumentImporting) {
        self.documentImporter = documentImporter
    }

    func execute(fileURL: URL) throws -> PDFDocument {
        try documentImporter.loadDocument(from: fileURL)
    }
}
