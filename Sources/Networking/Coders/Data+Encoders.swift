import Foundation

public extension Data {
  static func jsonEncode<T: Encodable>(_ body: T) throws -> Self {
    try JSONEncoder().encode(body)
  }
  
  static func formDataEncode<T: Encodable>(_ body: T) throws -> Self {
    try FormDataEncoder().encode(body)
  }
}
