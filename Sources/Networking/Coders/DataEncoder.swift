import Foundation

public protocol DataEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: DataEncoder {}
