import Foundation
import Networking

// MARK: - PageableHttpRequest

public protocol PageableHttpRequestProtocol: HttpRequestProtocol {
  /// Name of the query parameter for page number (e.g., "page", "offset")
  var pageQueryParameterName: String { get }

  /// Name of the query parameter for page size (e.g., "per_page", "limit")
  var pageSizeQueryParameterName: String { get }

  /// Number of items per page
  var pageSize: UInt { get }
}

public extension PageableHttpRequestProtocol {
  // Sensible defaults for most REST APIs
  var pageQueryParameterName: String { "page" }
  var pageSizeQueryParameterName: String { "per_page" }
  var pageSize: UInt { 20 }
}

extension PageableHttpRequestProtocol {
  func asURLRequest(page: UInt) throws -> URLRequest {
    var urlRequest = try asURLRequest()

    guard let url = urlRequest.url,
          var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw HttpError.badURL
    }

    var queryItems = urlComponents.queryItems ?? []
    queryItems.append(contentsOf: [
      URLQueryItem(name: pageQueryParameterName, value: String(page)),
      URLQueryItem(name: pageSizeQueryParameterName, value: String(pageSize))
    ])

    urlComponents.queryItems = queryItems

    guard let finalURL = urlComponents.url else {
      throw HttpError.badURL
    }

    urlRequest.url = finalURL
    return urlRequest
  }
}

// MARK: - HttpClient Extension

extension HttpClientProtocol {
  public func fetch<T: Decodable>(page: UInt,
                                  request: any PageableHttpRequestProtocol,
                                  decoder: DataDecoder = JSONDecoder()) async throws -> T {
    let urlRequest = try request.asURLRequest(page: page)
    let data = try await fetchData(request: urlRequest, decoder: decoder)
    return try decoder.decode(T.self, from: data)
  }
}
