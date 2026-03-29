import Foundation

struct AppContainer {
    func makeDocAskViewModel() -> DocAskViewModel {
        let documentImporter = LocalPDFDocumentLoader()
        let documentRepository = RemoteDocumentRepository()
        let questionRepository = RemoteQuestionRepository()

        return DocAskViewModel(
            importDocumentUseCase: DefaultImportDocumentUseCase(documentImporter: documentImporter),
            uploadDocumentUseCase: DefaultUploadDocumentUseCase(repository: documentRepository),
            askQuestionUseCase: DefaultAskQuestionUseCase(repository: questionRepository)
        )
    }
}
