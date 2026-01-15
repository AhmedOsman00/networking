import Foundation

final public class FormDataEncoder: Encoder, DataEncoder {
    internal let boundary: String
    private var encodedData = Data()

    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try value.encode(to: self)
        if !encodedData.isEmpty {
            encodedData.append(contentsOf: "--\(boundary)--\r\n".utf8)
        }
        return encodedData
    }

    public func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let container = FormDataKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unkeyed encoding is not supported for multipart/form-data")
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Single value encoding is not supported for multipart/form-data")
    }

    func append(_ data: Data) {
        encodedData.append(data)
    }
}
