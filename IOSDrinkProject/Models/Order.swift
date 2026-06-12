import Foundation

struct Order: Codable, Identifiable {
    let id: Int
    let customerName: String
    let phone: String
    let items: [OrderItem]
    let totalPrice: Int
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case customerName = "customer_name"
        case phone
        case items
        case totalPrice = "total_price"
        case status
        case createdAt = "created_at"
    }

    init(id: Int, customerName: String, phone: String, items: [OrderItem], totalPrice: Int, status: String? = nil, createdAt: String? = nil) {
        self.id = id
        self.customerName = customerName
        self.phone = phone
        self.items = items
        self.totalPrice = totalPrice
        self.status = status
        self.createdAt = createdAt
    }
}

struct OrderItem: Codable, Hashable {
    let drinkID: Int
    let drinkName: String?
    let quantity: Int
    let sweetness: String
    let iceLevel: String
    let unitPrice: Int?
    let subtotal: Int?

    enum CodingKeys: String, CodingKey {
        case drinkID = "drink_id"
        case drinkName = "drink_name"
        case quantity
        case sweetness
        case iceLevel = "ice_level"
        case unitPrice = "unit_price"
        case subtotal
    }
}

struct CreateOrderRequest: Codable {
    let customerName: String
    let phone: String
    let items: [CreateOrderItemRequest]

    enum CodingKeys: String, CodingKey {
        case customerName = "customer_name"
        case phone
        case items
    }
}

struct CreateOrderItemRequest: Codable {
    let drinkID: Int
    let quantity: Int
    let sweetness: String
    let iceLevel: String

    enum CodingKeys: String, CodingKey {
        case drinkID = "drink_id"
        case quantity
        case sweetness
        case iceLevel = "ice_level"
    }
}
