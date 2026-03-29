# DocAsk

DocAsk is an iOS app for uploading PDF documents and asking questions about their contents through a backend RAG service.

## Features

- Select PDF files from the iOS file system
- Upload documents with multipart form data
- Track upload and processing flow
- Ask questions in a chat-style interface
- Cancel ingestion and start over

## Setup

1. Clone the repository.
2. Create local config files:
   - `DocAsk/Config/Debug.xcconfig`
   - `DocAsk/Config/Release.xcconfig`
3. Set `API_BASE_URL` in each file.
4. Open `DocAsk.xcodeproj` in Xcode.
5. Build and run.

Example:

```xcconfig
API_BASE_URL = http://127.0.0.1:8000
```

Tracked templates:

- `DocAsk/Config/Debug.example.xcconfig`
- `DocAsk/Config/Release.example.xcconfig`

## Developer Notes

- The app uses SwiftUI with a Presentation / Domain / Data split.
- API base URL is read from `Info.plist`, backed by `xcconfig`.
- Local config files are ignored by git.
- Unit tests cover core view model flows with mocked use cases.

## Backend

Backend repository:

https://github.com/yemigabriel/rag_engine_backend
