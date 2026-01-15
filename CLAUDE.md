# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Swift Package Manager (SPM) library containing two products:
- **Networking**: Type-safe HTTP client with protocol-based design for iOS 15+
- **Pager**: Pagination utilities built on top of Networking

## Building & Testing

```bash
# Build the package
swift build

# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

## Architecture

### Networking Module

The networking layer follows a protocol-oriented design pattern:

1. **HttpRequestProtocol** - Defines the contract for HTTP requests with properties like `baseUrl`, `path`, `method`, `queryItems`, `body`, and `headers`. Contains extension that converts requests to `URLRequest` via `asURLRequest()`.

2. **HttpClientProtocol** - Defines the client interface with `fetchData()` and generic `fetch<T>()` methods. The protocol extension provides default implementation of `fetch()` that uses `fetchData()`.

3. **HttpClient** - Concrete implementation that:
   - Takes a generic `Error` type that must be `Decodable` for API error responses
   - Wraps `URLSessionProtocol` for testability
   - Validates responses against configurable success status code range (default 200-299)
   - Decodes API errors on non-success status codes and throws `HttpError.api(error)`
   - Supports optional logging via `NetworkLogger` protocol
   - Measures request duration and logs verbose details when enabled

4. **Error Handling** - `HttpError` enum with cases: `badURL`, `badResponse`, and `api(Error)` for decoded API errors

5. **Custom Encoders/Decoders**:
   - **DataEncoder/DataDecoder** protocols abstract encoding/decoding
   - **FormDataEncoder** - Custom encoder for multipart/form-data requests with boundary support
   - **FormDataFile** - Represents file attachments with filename, mimeType, and data

### Pager Module

The pagination system depends on Networking:

1. **Pageable** protocol - Responses must have `totalPages: UInt` property

2. **PageableHttpRequestProtocol** - Extends `HttpRequestProtocol` with:
   - `pageQueryParameterName` (default: "page")
   - `pageSizeQueryParameterName` (default: "per_page")
   - `pageSize` (default: 20)
   - Extension method `asURLRequest(page:)` that adds pagination query parameters

3. **Pager** actor - Thread-safe pagination state manager:
   - Tracks `currentPage` and `totalPages`
   - `nextPage()` - Fetches next page, updates state, returns nil when exhausted
   - `firstPage()` - Resets state and fetches page 1
   - `hasMorePages` - Computed property checking if more pages available

## Key Design Patterns

- **Protocol-oriented**: All major components have protocol interfaces for testability
- **Generic error types**: `HttpClient<E: Error&Decodable>` allows custom API error models
- **Actor isolation**: `Pager` uses Swift actors for safe concurrent pagination
- **Testability**: Mock implementations exist for `URLSession`, `HttpRequest`, and `HttpClient` in test targets
- **URLSessionProtocol wrapper**: Allows injecting mock session for testing without network calls

## Testing

Test structure mirrors source structure:
- `Tests/NetworkingTests/Client/` - HttpClient and URLRequest tests
- `Tests/NetworkingTests/Coders/` - Encoder/decoder tests
- `Tests/NetworkingTests/Pager/` - Pager functionality tests

Mock implementations provide:
- `MockURLSession` - Stub network responses
- `MockHttpRequest` - Test request building
- `MockHttpClient` - Test without real HTTP
- `MockPageableHttpRequest` - Test pagination logic
