import Testing
import Foundation
@testable import Networking

struct HttpRequestTests {
  @Test
  func asURLRequestSuccess() throws {
    // Arrange
    let endpoint = MockHttpRequest(baseUrl: URL(string: "https://example.com")!,
                                   path: "/test",
                                   method: .POST,
                                   queryItems: [.init(name: "q", value: "swift")],
                                   body: try .jsonEncode(["key": "value"]),
                                   headers: ["Authorization": "Bearer token"])
    
    // Act
    let request = try endpoint.asURLRequest()
    
    // Assert
    #expect(request.url?.absoluteString == "https://example.com/test?q=swift")
    #expect(request.httpMethod == "POST")
    #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer token")
    #expect(request.httpBody != nil)
  }

  @Test
  func invalidURL() throws {
    // Arrange
    let endpoint = MockHttpRequest(baseUrl: URL(string: "invalid-url")!,
                                   path: "/test",
                                   method: .GET)
    
    // Act & Assert
    #expect(throws: HttpError.badURL, performing: endpoint.asURLRequest)
  }
}
