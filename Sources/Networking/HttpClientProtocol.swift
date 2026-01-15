import Foundation

public protocol HttpClientProtocol {
  func fetchData(request: URLRequest, decoder: DataDecoder) async throws -> Data
  func fetch<T: Decodable>(request: any HttpRequestProtocol, decoder: DataDecoder) async throws -> T
}

extension HttpClientProtocol {
  public func fetch<T: Decodable>(request: any HttpRequestProtocol, decoder: DataDecoder) async throws -> T {
    let data = try await fetchData(request: request.asURLRequest(), decoder: decoder)
    return try decoder.decode(T.self, from: data)
  }
}
