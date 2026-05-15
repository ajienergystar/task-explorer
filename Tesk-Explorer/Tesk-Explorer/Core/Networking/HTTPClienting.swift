//
//  HTTPClienting.swift
//  Narrow abstraction over URLSession so requests can be mocked in unit tests (BankDKI-style protocol boundary).
//

import Foundation

protocol HTTPClienting: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
