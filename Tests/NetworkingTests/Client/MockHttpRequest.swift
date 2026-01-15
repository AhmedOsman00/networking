import Foundation
@testable import Networking

struct MockHttpRequest: HttpRequestProtocol, Equatable {
  var baseUrl: URL = URL(string: "https://example.com")!
  var path: String = "/mock"
  var method: HttpMethod = .GET
  var queryItems: [URLQueryItem]? = []
  var body: Data? = nil
  var headers: [String: String] = [:]
}
