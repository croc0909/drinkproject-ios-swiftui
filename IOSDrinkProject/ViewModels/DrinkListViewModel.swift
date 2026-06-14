import Foundation
import OSLog

@MainActor
final class DrinkListViewModel: ObservableObject {
    @Published private(set) var drinks: [Drink] = []
    @Published private(set) var cartItems: [CartItem] = []
    @Published var note = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSubmitOrder = false

    private let apiClient: APIClient
    private let tokenStore: UserDefaults
    private let tokenKey = "authToken"
    private let logger = Logger(subsystem: "com.andylin.IOSDrinkProject", category: "DrinkListViewModel")

    var totalPrice: Int {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }

    var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    init(
        apiClient: APIClient = .shared,
        tokenStore: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func loadDrinks() async {
        logger.info("[DrinkList] Start loading drinks")
        isLoading = true
        errorMessage = nil

        do {
            drinks = try await apiClient.fetchDrinks()
            logger.info("[DrinkList] Showing \(self.drinks.count, privacy: .public) drinks from Go backend")
        } catch {
            drinks = Drink.samples
            errorMessage = "目前使用範例資料，請確認 Go 後端是否已啟動。"
            logger.error("[DrinkList] Failed to load drinks from Go backend. Showing sample data instead. Error: \(error.localizedDescription, privacy: .public)")
        }

        isLoading = false
        logger.info("[DrinkList] Finished loading drinks")
    }

    func addToCart(_ drink: Drink) {
        if let index = cartItems.firstIndex(where: { $0.drink.id == drink.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(drink: drink, quantity: 1))
        }
    }

    func removeFromCart(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    func submitOrder() async {
        guard !cartItems.isEmpty else { return }

        guard let token = tokenStore.string(forKey: tokenKey) else {
            errorMessage = "請先登入會員後再送出訂單。"
            logger.info("[DrinkList] Submit order blocked because auth token is missing")
            return
        }

        do {
            let user = try await apiClient.fetchMe(token: token)
            let orderRequest = CreateOrderRequest(
                customerName: user.name,
                items: cartItems.map {
                    CreateOrderItemRequest(
                        drinkID: $0.drink.id,
                        quantity: $0.quantity,
                        sweetness: "半糖",
                        iceLevel: "少冰"
                    )
                }
            )

            logger.info("[DrinkList] Submit order to Go backend, items: \(self.cartItems.count, privacy: .public), total: \(self.totalPrice, privacy: .public)")
            _ = try await apiClient.submitOrder(orderRequest, token: token)
            cartItems.removeAll()
            note = ""
            didSubmitOrder = true
            logger.info("[DrinkList] Order submitted successfully")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("[DrinkList] Submit order failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
