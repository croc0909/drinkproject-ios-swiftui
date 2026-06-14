import Foundation
import OSLog

@MainActor
final class OrderRecordsViewModel: ObservableObject {
    @Published private(set) var orders: [Order] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let apiClient: APIClient
    private let tokenStore: UserDefaults
    private let tokenKey = "authToken"
    private let user: User
    private let logger = Logger(subsystem: "com.andylin.IOSDrinkProject", category: "OrderRecordsViewModel")

    init(
        user: User,
        apiClient: APIClient = .shared,
        tokenStore: UserDefaults = .standard
    ) {
        self.user = user
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func loadOrders() async {
        guard !isLoading else { return }

        guard let token = tokenStore.string(forKey: tokenKey) else {
            errorMessage = "請先登入會員後再查看訂單紀錄。"
            orders = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            logger.info("[Order Records] Fetching orders for user id \(self.user.id, privacy: .public)")
            let fetchedOrders = try await apiClient.fetchOrders(token: token)
            orders = fetchedOrders.sorted { $0.id > $1.id }
            logger.info("[Order Records] Loaded \(self.orders.count, privacy: .public) orders for current user")
        } catch {
            logger.error("[Order Records] Failed to load orders: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
            orders = []
        }

        isLoading = false
    }

    func refreshOrders() async {
        isLoading = false
        await loadOrders()
    }
}
