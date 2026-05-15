//
//  TodoRemoteDataSource.swift
//  Responsible only for retrieving and decoding todos from JSONPlaceholder.
//

import Foundation

protocol TodoRemoteDataSourcing: Sendable {
    func fetchTodos() async throws -> [TodoDTO]
}

struct TodoRemoteDataSource: TodoRemoteDataSourcing {
    private let baseURL: URL
    private let http: HTTPClienting
    private let decoder: JSONDecoder

    init(
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!,
        http: HTTPClienting,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.http = http
        self.decoder = decoder
    }

    func fetchTodos() async throws -> [TodoDTO] {
        guard let url = URL(string: "/todos", relativeTo: baseURL)?.absoluteURL else {
            throw NetworkingError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await http.data(for: request)
        } catch {
            throw NetworkingError.transport(underlyingDescription: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse(statusCode: -1)
        }
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw NetworkingError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        guard !data.isEmpty else {
            throw NetworkingError.emptyData
        }

        do {
            return try decoder.decode([TodoDTO].self, from: data)
        } catch {
            throw NetworkingError.decodingFailed(underlyingDescription: error.localizedDescription)
        }
    }
}
