import Foundation

struct FormDataKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var encoder: FormDataEncoder
    var codingPath: [CodingKey] {
        encoder.codingPath
    }

    mutating func encodeNil(forKey key: Key) throws {}

    mutating func encode(_ value: String, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: value)
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        appendFormField(name: key.stringValue, value: "\(value)")
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        // FormFile gets special binary file encoding
        if let file = value as? FormDataFile {
            appendFileField(file: file, name: key.stringValue)
        } else {
            // Everything else: JSON encode and send as string value
            // This handles primitives, arrays, nested objects, etc.
            let jsonData = try JSONEncoder().encode(value)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                appendFormField(name: key.stringValue, value: jsonString)
            }
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = FormDataKeyedEncodingContainer<NestedKey>(encoder: encoder)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        fatalError("Nested unkeyed encoding is not supported for multipart/form-data")
    }

    mutating func superEncoder() -> any Encoder {
        return encoder
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        return encoder
    }

    private mutating func appendFormField(name: String, value: String) {
        var fieldData = Data()
        fieldData.append(contentsOf: "--\(encoder.boundary)\r\n".utf8)
        fieldData.append(contentsOf: "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8)
        fieldData.append(contentsOf: value.utf8)
        fieldData.append(contentsOf: "\r\n".utf8)
        encoder.append(fieldData)
    }

    private mutating func appendFileField(file: FormDataFile, name: String) {
        var fieldData = Data()
        fieldData.append(contentsOf: "--\(encoder.boundary)\r\n".utf8)
        fieldData.append(contentsOf: "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(file.filename)\"\r\n".utf8)
        fieldData.append(contentsOf: "Content-Type: \(file.mimeType)\r\n\r\n".utf8)
        fieldData.append(file.data)
        fieldData.append(contentsOf: "\r\n".utf8)
        encoder.append(fieldData)
    }
}
