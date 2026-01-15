import Foundation

public protocol NetworkLogger {
  func log(_ message: String)
}

extension NetworkLogger {
  func logRequest(_ request: URLRequest) {
    log("🔧 cURL: \(request.asCurl())")
  }

  func logResponse(_ response: HTTPURLResponse, succeeded: Bool, data: Data, duration: TimeInterval) {
    let statusEmoji = succeeded ? "✅" : "❌"
    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    log("\(statusEmoji) Response: \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
    log("⏱️  Duration: \(String(format: "%.3f", duration))s")
    log("📦 Data size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))")

    if let headers = response.allHeaderFields as? [String: String], !headers.isEmpty {
      log("📋 Headers:")
      headers.forEach { key, value in
        log("  \(key): \(value)")
      }
    }

    if let responseString = String(data: data, encoding: .utf8) {
      log("📄 Response body:\n\(responseString)")
    }
    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  }

  func logError(_ message: String) {
    log("⚠️ \(message)")
  }
}

extension URLRequest {
  func asCurl() -> String {
    guard let url else { return "" }

    var components: [String] = ["curl -X \(httpMethod ?? "")"]
    components.append("'\(url.absoluteString)'")

    for (key, value) in allHTTPHeaderFields ?? [:] {
      let escapedValue = value.replacingOccurrences(of: "'", with: "'\\''")
      components.append("-H '\(key): \(escapedValue)'")
    }

    if let bodyData = httpBody,
       let bodyString = String(data: bodyData, encoding: .utf8) {
      let escapedBodyString = bodyString.replacingOccurrences(of: "'", with: "'\\''")
      components.append("-d '\(escapedBodyString)'")
    }

    return components.joined(separator: " ")
  }
}
