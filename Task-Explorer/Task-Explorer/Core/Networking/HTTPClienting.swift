// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

protocol HTTPClienting: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
