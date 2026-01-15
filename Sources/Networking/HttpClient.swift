import Foundation

public class HttpClient<E: Error&Decodable>: HttpClientProtocol {
  private let successStatusCodeRange: ClosedRange<Int>
  private let session: URLSessionProtocol
  private let logger: NetworkLogger?
  private let verbose: Bool

  public init(session: URLSessionProtocol = URLSession.default,
              successStatusCodeRange: ClosedRange<Int> = 200...299,
              logger: NetworkLogger? = nil,
              verbose: Bool = false) {
    self.session = session
    self.successStatusCodeRange = successStatusCodeRange
    self.logger = logger
    self.verbose = verbose
  }

  public func fetchData(request: URLRequest, decoder: DataDecoder) async throws -> Data {
    let startTime = CFAbsoluteTimeGetCurrent()
    log { $0.logRequest(request) }

    let (data, httpResponse) = try await performRequest(request)
    let response = try validateResponse(httpResponse)

    let duration = CFAbsoluteTimeGetCurrent() - startTime
    let succeeded = successStatusCodeRange ~= response.statusCode

    log { $0.logResponse(response, succeeded: succeeded, data: data, duration: duration) }

    guard succeeded else {
      try handleErrorResponse(data: data, statusCode: response.statusCode, decoder: decoder)
    }

    return data
  }

  private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
    do {
      return try await session.data(request)
    } catch {
      log { $0.logError("Network request failed: \(error.localizedDescription)") }
      throw error
    }
  }

  private func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
    guard let httpResponse = response as? HTTPURLResponse else {
      log { $0.logError("Invalid response type - expected HTTPURLResponse") }
      throw HttpError.badResponse
    }
    return httpResponse
  }

  private func handleErrorResponse(data: Data, statusCode: Int, decoder: DataDecoder) throws -> Never {
    let error: E
    do {
      error = try decoder.decode(E.self, from: data)
    } catch {
      log { $0.logError("Failed to decode API error: \(error). Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")") }
      throw error
    }
    log { $0.logError("API error (\(statusCode)): \(error)") }
    throw HttpError.api(error)
  }

  private func log(_ action: (NetworkLogger) -> Void) {
    guard let logger, verbose else { return }
    action(logger)
  }
}
