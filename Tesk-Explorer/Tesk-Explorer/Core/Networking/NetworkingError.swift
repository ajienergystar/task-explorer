// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

enum NetworkingError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case emptyData
    case decodingFailed(underlyingDescription: String)
    case transport(underlyingDescription: String)

    var userMessage: String {
        switch self {
        case .invalidURL:
            String(localized: "Invalid request URL.")
        case let .invalidResponse(code):
            String(localized: "Unexpected response (HTTP \(code)).")
        case .emptyData:
            String(localized: "Empty response body.")
        case let .decodingFailed(description):
            String(localized: "Could not read data: \(description)")
        case let .transport(description):
            String(localized: "Network error: \(description)")
        }
    }
}
