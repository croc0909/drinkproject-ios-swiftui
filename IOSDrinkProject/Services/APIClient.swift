import Foundation
import OSLog

enum APIError: LocalizedError {
    case invalidResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "伺服器回應格式不正確。"
        case .requestFailed(let message):
            return message
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "http://localhost:8080/api")!
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "com.andylin.IOSDrinkProject", category: "APIClient")

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchDrinks() async throws -> [Drink] {
        let url = baseURL.appending(path: "drinks")
        logger.info("[API] GET drinks request -> \(url.absoluteString, privacy: .public)")

        let (data, response) = try await urlSession.data(from: url)
        try validate(response, endpoint: "GET /api/drinks")

        let drinks = try JSONDecoder().decode([Drink].self, from: data)
        logger.info("[API] GET drinks success <- decoded \(drinks.count, privacy: .public) drinks from Go backend")
        return drinks
    }

    func submitOrder(_ orderRequest: CreateOrderRequest, token: String) async throws -> Order {
        let url = baseURL.appending(path: "orders")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(orderRequest)

        logger.info("[API] POST order request -> \(url.absoluteString, privacy: .public), items: \(orderRequest.items.count, privacy: .public), token attached: \(!token.isEmpty, privacy: .public)")

        let (data, response) = try await urlSession.data(for: request)
        try validate(response, data: data, endpoint: "POST /api/orders")

        let order = try JSONDecoder().decode(Order.self, from: data)

        logger.info("[API] POST order success <- Go backend created order id \(order.id, privacy: .public)")
        return order
    }

    func fetchOrders(token: String) async throws -> [Order] {
        let url = baseURL.appending(path: "me/orders")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        logger.info("[API] GET me/orders request -> \(url.absoluteString, privacy: .public), token attached: \(!token.isEmpty, privacy: .public)")

        let (data, response) = try await urlSession.data(for: request)
        logger.info("[API] GET me/orders response received <- \(data.count, privacy: .public) bytes")
        try validate(response, data: data, endpoint: "GET /api/me/orders")

        let orders = try JSONDecoder().decode([Order].self, from: data)
        logger.info("[API] GET me/orders success <- decoded \(orders.count, privacy: .public) orders")
        return orders
    }

    func register(phone: String, name: String, password: String) async throws -> AuthResponse {
        let requestBody = RegisterRequest(phone: phone, name: name, password: password)
        let request = try makeJSONRequest(path: "auth/register", method: "POST", body: requestBody)

        logger.info("[Auth API] Register request prepared -> \(request.url?.absoluteString ?? "", privacy: .public), phone: \(phone, privacy: .private(mask: .hash)), name: \(name, privacy: .private(mask: .hash))")

        let (data, response) = try await urlSession.data(for: request)
        logger.info("[Auth API] Register response received <- \(data.count, privacy: .public) bytes")
        try validate(response, data: data, endpoint: "POST /api/auth/register")

        logger.info("[Auth API] Register decoding AuthResponse")
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        logger.info("[Auth API] Register success <- user id \(authResponse.user.id, privacy: .public), token received: \(!authResponse.token.isEmpty, privacy: .public)")
        return authResponse
    }

    func login(phone: String, password: String) async throws -> AuthResponse {
        let requestBody = LoginRequest(phone: phone, password: password)
        let request = try makeJSONRequest(path: "auth/login", method: "POST", body: requestBody)

        logger.info("[Auth API] Login request prepared -> \(request.url?.absoluteString ?? "", privacy: .public), phone: \(phone, privacy: .private(mask: .hash))")

        let (data, response) = try await urlSession.data(for: request)
        logger.info("[Auth API] Login response received <- \(data.count, privacy: .public) bytes")
        try validate(response, data: data, endpoint: "POST /api/auth/login")

        logger.info("[Auth API] Login decoding AuthResponse")
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        logger.info("[Auth API] Login success <- user id \(authResponse.user.id, privacy: .public), token received: \(!authResponse.token.isEmpty, privacy: .public)")
        return authResponse
    }

    func fetchMe(token: String) async throws -> User {
        let url = baseURL.appending(path: "me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        logger.info("[Auth API] Me request prepared -> \(url.absoluteString, privacy: .public), token attached: \(!token.isEmpty, privacy: .public)")

        let (data, response) = try await urlSession.data(for: request)
        logger.info("[Auth API] Me response received <- \(data.count, privacy: .public) bytes")
        try validate(response, data: data, endpoint: "GET /api/me")

        logger.info("[Auth API] Me decoding User")
        let user = try JSONDecoder().decode(User.self, from: data)
        logger.info("[Auth API] Me success <- user id \(user.id, privacy: .public)")
        return user
    }

    private func validate(_ response: URLResponse, endpoint: String) throws {
        try validate(response, data: nil, endpoint: endpoint)
    }

    private func validate(_ response: URLResponse, data: Data?, endpoint: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("[API] \(endpoint, privacy: .public) failed: response is not HTTPURLResponse")
            throw APIError.invalidResponse
        }

        logger.info("[API] \(endpoint, privacy: .public) status code: \(httpResponse.statusCode, privacy: .public)")

        guard (200..<300).contains(httpResponse.statusCode) else {
            logger.error("[API] \(endpoint, privacy: .public) failed with status code: \(httpResponse.statusCode, privacy: .public)")
            if let data,
               let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
               !errorResponse.error.isEmpty {
                logger.error("[API] \(endpoint, privacy: .public) backend error body: \(errorResponse.error, privacy: .public)")
                throw APIError.requestFailed(errorResponse.error)
            }

            logger.error("[API] \(endpoint, privacy: .public) failed without decodable error body")
            throw APIError.requestFailed("無法連線到後端服務。")
        }

        logger.info("[API] \(endpoint, privacy: .public) validation passed")
    }

    private func makeJSONRequest<Body: Encodable>(path: String, method: String, body: Body) throws -> URLRequest {
        let url = baseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        logger.debug("[API] JSON request encoded -> \(method, privacy: .public) \(url.absoluteString, privacy: .public), body bytes: \(request.httpBody?.count ?? 0, privacy: .public)")
        return request
    }
}
