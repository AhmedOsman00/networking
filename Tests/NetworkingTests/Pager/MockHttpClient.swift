import Foundation
import Networking

final class MockHttpClient: HttpClientProtocol {
  var fetchedPages = [UInt]()
  var mockResponses: [UInt: Data] = [:]

  func fetchData(request: URLRequest, decoder: any DataDecoder) async throws -> Data {
    let queryItems = URLComponents(url: request.url!, resolvingAgainstBaseURL: false )?.queryItems ?? []
    let page = queryItems.first(where: { $0.name == "page" })?.value.flatMap(UInt.init) ?? 0
    fetchedPages.append(page)
    return mockResponses[page]!
  }
}
