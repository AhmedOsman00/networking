import Foundation
@testable import Networking

class MockURLSession: URLSessionProtocol {
  var dataToReturn: Data
  var responseToReturn: URLResponse

  static var `default`: any URLSessionProtocol = MockURLSession()

  init(dataToReturn: Data = Data(), responseToReturn: URLResponse = URLResponse()) {
    self.dataToReturn = dataToReturn
    self.responseToReturn = responseToReturn
  }

  func data(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
    return (dataToReturn, responseToReturn)
  }
}
