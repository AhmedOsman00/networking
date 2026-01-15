import Testing
import Foundation
@testable import Networking

struct MockModel: Decodable {
    let name: String
}

struct MockError: Error, Decodable {
  let message: String
}

struct HttpClientTests {
    let mockSession: MockURLSession
    let sut: HttpClient<MockError>

    init() {
        self.mockSession = MockURLSession()
        self.sut = HttpClient<MockError>(session: mockSession)
    }

    @Test
    func successfulResponse() async throws {
        // Arrange
        let mockData = "{\"name\":\"Test\"}".data(using: .utf8)!
        mockSession.dataToReturn = mockData
        mockSession.responseToReturn = createHTTPURLResponse(statusCode: 200)

        // Act
        let result: MockModel = try await sut.fetch(request: MockHttpRequest(), decoder: JSONDecoder())

        // Assert
        #expect(result.name == "Test")
    }

    @Test
    func failedResponseWithAPIError() async throws {
        // Arrange
        let mockData = "{\"message\":\"Invalid request\"}".data(using: .utf8)!
        mockSession.dataToReturn = mockData
        mockSession.responseToReturn = createHTTPURLResponse(statusCode: 400)

        // Act & Assert
        let error = HttpError.api(MockError(message: "Invalid request"))
        await #expect(throws: error, performing: {
            let _: MockModel = try await sut.fetch(request: MockHttpRequest(), decoder: JSONDecoder())
        })
    }

    func createHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
        .init(url: URL(string: "https://example.com")!,
              statusCode: statusCode,
              httpVersion: nil,
              headerFields: nil)!
    }
}
