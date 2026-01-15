import Foundation

public struct FormDataFile: Encodable {
    public let filename: String
    public let mimeType: String
    public let data: Data
    
    public init(filename: String, mimeType: String, data: Data) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
    
    public func encode(to encoder: any Encoder) throws {
        // FormFile should only be encoded as part of a keyed container
        // This method exists to satisfy Encodable but shouldn't be called directly
        throw EncodingError.invalidValue(
            self,
            EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "FormFile must be encoded as a property of a struct with FormDataEncoder"
            )
        )
    }
}
