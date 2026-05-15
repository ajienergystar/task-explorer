// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

final class URLSessionHTTPClient: HTTPClienting {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
