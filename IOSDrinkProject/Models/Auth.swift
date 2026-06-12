import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: Int
    let phone: String
    let name: String
}

struct RegisterRequest: Codable {
    let phone: String
    let name: String
    let password: String
}

struct LoginRequest: Codable {
    let phone: String
    let password: String
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct ErrorResponse: Codable {
    let error: String
}
