# Networking

A light, type-safe networking library for Swift with built-in pagination support.

## Features

- **Protocol-oriented design** for easy testing and mocking
- **Type-safe HTTP requests** with compile-time guarantees
- **Generic error handling** with decodable API errors
- **Built-in pagination** with the Pager module
- **FormData encoding** for multipart file uploads
- **Network logging** with cURL command generation
- **Swift concurrency** with async/await support
- **Actor-based pagination** for thread-safe state management

## Requirements

- iOS 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/networking.git", from: "1.0.0")
]
```

Then add the products to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Networking", package: "networking"),
        .product(name: "Pager", package: "networking")  // Optional, for pagination
    ]
)
```

## Usage

### Basic HTTP Request

Define your request by conforming to `HttpRequestProtocol`:

```swift
import Networking

struct GetUserRequest: HttpRequestProtocol {
    let userId: Int

    var baseUrl: URL { URL(string: "https://api.example.com")! }
    var path: String { "/users/\(userId)" }
    var method: HttpMethod { .GET }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var headers: [String: String] { ["Accept": "application/json"] }
}
```

### Making Requests

Create an HTTP client with your custom error type:

```swift
struct APIError: Error, Decodable {
    let message: String
    let code: String
}

let client = HttpClient<APIError>()

// Fetch decoded response
let user: User = try await client.fetch(
    request: GetUserRequest(userId: 123),
    decoder: JSONDecoder()
)
```

### Custom Error Handling

The client automatically decodes API errors on non-2xx responses:

```swift
do {
    let user: User = try await client.fetch(request: request, decoder: JSONDecoder())
} catch HttpError.api(let apiError) {
    // Handle your custom APIError
    if let error = apiError as? APIError {
        print("API Error: \(error.message)")
    }
} catch HttpError.badURL {
    print("Invalid URL")
} catch HttpError.badResponse {
    print("Invalid response")
}
```

### Network Logging

Enable verbose logging with a custom logger:

```swift
class ConsoleLogger: NetworkLogger {
    func log(_ message: String) {
        print(message)
    }
}

let client = HttpClient<APIError>(
    logger: ConsoleLogger(),
    verbose: true
)
```

### FormData Uploads

Use `FormDataEncoder` for multipart file uploads:

```swift
import Networking

struct UploadRequest: HttpRequestProtocol {
    let file: FormDataFile

    var baseUrl: URL { URL(string: "https://api.example.com")! }
    var path: String { "/upload" }
    var method: HttpMethod { .POST }
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String: String] {
        let encoder = FormDataEncoder()
        return [
            "Content-Type": "multipart/form-data; boundary=\(encoder.boundary)"
        ]
    }

    var body: Data? {
        let encoder = FormDataEncoder()
        try? encoder.encode(["file": file])
    }
}

let file = FormDataFile(
    filename: "photo.jpg",
    mimeType: "image/jpeg",
    data: imageData
)
```

### Pagination

Use the `Pager` module for paginated API responses:

```swift
import Pager
import Networking

// 1. Define your pageable response
struct UsersResponse: Pageable {
    let users: [User]
    let totalPages: UInt
}

// 2. Create a pageable request
struct GetUsersRequest: PageableHttpRequestProtocol {
    var baseUrl: URL { URL(string: "https://api.example.com")! }
    var path: String { "/users" }
    var method: HttpMethod { .GET }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var headers: [String: String] { ["Accept": "application/json"] }

    // Pagination configuration (optional, these are the defaults)
    var pageQueryParameterName: String { "page" }
    var pageSizeQueryParameterName: String { "per_page" }
    var pageSize: UInt { 20 }
}

// 3. Use the pager
let client = HttpClient<APIError>()
let pager = Pager(httpClient: client)

// Fetch first page
if let firstPage: UsersResponse = try await pager.firstPage(
    request: GetUsersRequest(),
    decoder: JSONDecoder()
) {
    print("Loaded \(firstPage.users.count) users")
}

// Fetch next page
while await pager.hasMorePages {
    if let nextPage: UsersResponse = try await pager.nextPage(
        request: GetUsersRequest(),
        decoder: JSONDecoder()
    ) {
        print("Loaded \(nextPage.users.count) more users")
    }
}
```

## Testing

The library provides protocols for easy mocking:

```swift
import Networking

class MockHttpClient: HttpClientProtocol {
    var mockData: Data?
    var mockError: Error?

    func fetchData(request: URLRequest, decoder: DataDecoder) async throws -> Data {
        if let error = mockError {
            throw error
        }
        return mockData ?? Data()
    }
}

// Use in tests
let mockClient = MockHttpClient()
mockClient.mockData = """
{"users": [], "totalPages": 0}
""".data(using: .utf8)

let pager = Pager(httpClient: mockClient)
```
