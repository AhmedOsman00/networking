import Foundation
import Testing
@testable import Networking

@Suite
struct FormDataEncoderTests {

    @Test
    func testEncodingSimpleValues() throws {
        struct TestForm: Encodable {
            let name: String
            let age: Int
            let isActive: Bool
            let score: Double
        }

        let form = TestForm(name: "John Doe", age: 30, isActive: true, score: 95.5)
        let encoder = FormDataEncoder(boundary: "TestBoundary")
        let encodedData = try encoder.encode(form)
        let expectedBody = "--TestBoundary\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nJohn Doe\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"age\"\r\n\r\n30\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"isActive\"\r\n\r\ntrue\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"score\"\r\n\r\n95.5\r\n--TestBoundary--\r\n"
        let encodedString = String(data: encodedData, encoding: .utf8) ?? ""
        #expect(encodedString == expectedBody)
    }

    @Test
    func testEncodingFile() throws {
        struct TestForm: Encodable {
            let profilePicture: FormDataFile
        }

        let file = FormDataFile(filename: "image.jpg", mimeType: "image/jpeg", data: Data([0xFF, 0xD8, 0xFF]))
        let form = TestForm(profilePicture: file)
        let encoder = FormDataEncoder(boundary: "TestBoundary")
        let encodedData = try encoder.encode(form)
        let expectedBody = Data("--TestBoundary\r\nContent-Disposition: form-data; name=\"profilePicture\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".utf8) + Data([0xFF, 0xD8, 0xFF]) + Data("\r\n--TestBoundary--\r\n".utf8)
        #expect(encodedData == expectedBody, "Encoded body does not match expected output")
    }

    @Test
    func testJsonValue() throws {
        struct TestForm: Encodable {
            let object: TestObject
            
            struct TestObject: Encodable {
                let name: String
            }
        }

        let form = TestForm(object: .init(name: "Test"))
        let encoder = FormDataEncoder(boundary: "TestBoundary")
        let encodedData = try encoder.encode(form)
        let expectedBody = "--TestBoundary\r\nContent-Disposition: form-data; name=\"object\"\r\n\r\n{\"name\":\"Test\"}\r\n--TestBoundary--\r\n"
        let encodedString = String(data: encodedData, encoding: .utf8) ?? ""
        #expect(encodedString == expectedBody)
    }
    
    @Test
    func testOptionalValue() throws {
        struct TestForm: Encodable {
            let name: String?
        }

        let form = TestForm(name: nil)
        let encoder = FormDataEncoder(boundary: "TestBoundary")
        let encodedData = try encoder.encode(form)
        let encodedString = String(data: encodedData, encoding: .utf8) ?? ""
        #expect(encodedString == "")
    }
    
    @Test
    func testMixedValues() throws {
        struct TestForm: Encodable {
            let name: String
            let age: UInt
            let title: String?
            let description: String?
            let nested: NestedTestForm
            let pp: FormDataFile
            let score: Float
            
            struct NestedTestForm: Encodable {
                let nestedName: String?
            }
        }

        let form = TestForm(name: "John Doe",
                                    age: 30,
                                    title: "Software Engineer",
                                    description: nil,
                                    nested: TestForm.NestedTestForm(nestedName: "Nested Value"),
                                    pp: FormDataFile(filename: "profile.jpg", mimeType: "image/jpeg", data: Data([0xFF, 0xD8, 0xFF])),
                                    score: 98.6)
        let encoder = FormDataEncoder(boundary: "TestBoundary")
        let encodedData = try encoder.encode(form)
        let expectedData = Data("--TestBoundary\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nJohn Doe\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"age\"\r\n\r\n30\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"title\"\r\n\r\nSoftware Engineer\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"nested\"\r\n\r\n{\"nestedName\":\"Nested Value\"}\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"pp\"; filename=\"profile.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".utf8) + Data([0xFF, 0xD8, 0xFF]) + Data("\r\n--TestBoundary\r\nContent-Disposition: form-data; name=\"score\"\r\n\r\n98.6\r\n--TestBoundary--\r\n".utf8)
        #expect(encodedData == expectedData, "Encoded body does not match expected output")
    }
}
