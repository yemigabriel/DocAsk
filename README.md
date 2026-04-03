# DocAsk

DocAsk is an iOS app for uploading PDF documents and asking questions about their contents through a [backend RAG service](https://github.com/yemigabriel/rag_engine_backend).


## Preview

Screen recording: [Demo](https://github.com/user-attachments/assets/4a6211e0-9551-4cc1-837b-26c5bc5260d4)

| Welcome | Progress | Chat |
|---|---|---|
| ![Welcome](https://github.com/user-attachments/assets/0c50b9ea-3bc4-4bc7-8e49-a8bb1c505a76) | ![Progress](https://github.com/user-attachments/assets/b642b0f7-0e42-441e-8d0b-9dbf803b19fa) | ![Chat](https://github.com/user-attachments/assets/5ac84650-b3a0-4dcc-b324-b4cbe12ed6c5) |


## Features

- Import PDF files from the iOS file system
- Upload documents for background ingestion
- Track ingestion status until the document is ready
- Ask questions in a chat interface
- Stream answers from the backend


## Tech

- SwiftUI
- MVVM with a clean Presentation / Domain / Data split
- Swift concurrency with async/await
- `fileImporter` for PDF selection


## Setup

1. Clone the repository.
2. Create local config files:
   - `DocAsk/Config/Debug.xcconfig`
   - `DocAsk/Config/Release.xcconfig`
3. Set `API_BASE_URL` in each file.
4. Open `DocAsk.xcodeproj` in Xcode.
5. Build and run.


## Notes

- Uploads are handled as background jobs by the backend.
- The app polls job status before enabling chat.
- Chat answers are streamed from /ask​/stream.
- Local config files are ignored by git.


## Backend

Backend repository:

https://github.com/yemigabriel/rag_engine_backend
