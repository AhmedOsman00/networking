import Foundation

public enum HttpMethod: String {
  case GET, POST, PUT, DELETE, PATCH
}

public protocol HttpRequestProtocol: Hashable {
  var baseUrl: URL { get }
  var path: String { get }
  var method: HttpMethod { get }
  var queryItems: [URLQueryItem]? { get }
  var body: Data? { get }
  var headers: [String: String] { get }

  func asURLRequest() throws -> URLRequest
}

extension HttpRequestProtocol {
  public func asURLRequest() throws -> URLRequest {
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = path
    urlComponents?.queryItems = queryItems

    guard let url = urlComponents?.url,
      url.scheme != nil,
      url.host != nil
    else { throw HttpError.badURL }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    urlRequest.allHTTPHeaderFields = headers
    urlRequest.httpBody = body

    return urlRequest
  }
}
