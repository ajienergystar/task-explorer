// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

struct TodoDTO: Decodable, Equatable, Sendable {
    let id: Int
    let title: String
    let completed: Bool
}
