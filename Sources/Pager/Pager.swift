import Foundation
import Networking

// MARK: - Protocols

public protocol Pageable: Decodable {
  var totalPages: UInt { get }
}

public protocol PagerProtocol {
  var currentPage: UInt { get async }
  var totalPages: UInt? { get async }
  var hasMorePages: Bool { get async }

  func nextPage<T: Pageable>(request: any PageableHttpRequestProtocol, decoder: DataDecoder) async throws -> T?
  func firstPage<T: Pageable>(request: any PageableHttpRequestProtocol, decoder: DataDecoder) async throws -> T?
}

// MARK: - Pager Implementation

public actor Pager: PagerProtocol {
  private let httpClient: HttpClientProtocol
  private var _currentPage: UInt = 0
  private var _totalPages: UInt?

  public nonisolated var currentPage: UInt {
    get async {
      await _currentPage
    }
  }

  public nonisolated var totalPages: UInt? {
    get async {
      await _totalPages
    }
  }

  public nonisolated var hasMorePages: Bool {
    get async {
      guard let total = await _totalPages else {
        return true // Unknown, assume there might be more
      }
      return await _currentPage < total
    }
  }

  public init(httpClient: HttpClientProtocol) {
    self.httpClient = httpClient
  }

  public func nextPage<T: Pageable>(request: any PageableHttpRequestProtocol,
                                    decoder: DataDecoder = JSONDecoder()) async throws -> T? {
    if let total = _totalPages, _currentPage >= total {
      return nil
    }

    let pageToFetch = _currentPage + 1

    let page: T = try await httpClient.fetch(
      page: pageToFetch,
      request: request,
      decoder: decoder
    )

    _currentPage = pageToFetch
    _totalPages = page.totalPages

    return page
  }

  public func firstPage<T: Pageable>(request: any PageableHttpRequestProtocol,
                                     decoder: DataDecoder = JSONDecoder()) async throws -> T? {
    _currentPage = 0
    _totalPages = nil
    return try await nextPage(request: request, decoder: decoder)
  }
}
