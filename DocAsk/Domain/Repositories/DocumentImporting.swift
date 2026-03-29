import Foundation

protocol DocumentImporting {
    func loadDocument(from fileURL: URL) throws -> PDFDocument
}
