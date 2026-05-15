//
//  TodoDTO.swift
//  JSONPlaceholder wire format (extra keys such as `userId` are ignored by `Decodable`).
//

import Foundation

struct TodoDTO: Decodable, Equatable, Sendable {
    let id: Int
    let title: String
    let completed: Bool
}
