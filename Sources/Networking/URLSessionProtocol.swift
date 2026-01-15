import Foundation

public protocol URLSessionProtocol {
    static var `default`: URLSessionProtocol { get }
    func data(_ urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    public static var `default`: any URLSessionProtocol {
        URLSession.shared
    }

    public func data(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: urlRequest)
    }
}
