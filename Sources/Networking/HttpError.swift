import Foundation

public enum HttpError: Equatable, Error {
  case badURL
  case badResponse
  case api(Error)

  static public func == (lhs: HttpError, rhs: HttpError) -> Bool {
    switch (lhs, rhs) {
    case (.badURL, .badURL): return true
    case (.badResponse, .badResponse): return true
    case let (.api(lhsError), .api(rhsError)): return lhsError as NSError == rhsError as NSError
    default: return false
    }
  }
}
