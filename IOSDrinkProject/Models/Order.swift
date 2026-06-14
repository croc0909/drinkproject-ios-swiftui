import Foundation

struct Order: Codable, Identifiable {
    let id: Int
    let orderNo: String?
    let customerName: String
    let phone: String
    let items: [OrderItem]
    let totalPrice: Int
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderNo = "order_no"
        case customerName = "customer_name"
        case phone
        case items
        case totalPrice = "total_price"
        case status
        case createdAt = "created_at"
    }

    init(id: Int, orderNo: String? = nil, customerName: String, phone: String, items: [OrderItem], totalPrice: Int, status: String? = nil, createdAt: String? = nil) {
        self.id = id
        self.orderNo = orderNo
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
    let items: [CreateOrderItemRequest]

    enum CodingKeys: String, CodingKey {
        case customerName = "customer_name"
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

extension Order {
    var displayOrderNo: String {
        if let orderNo, !orderNo.isEmpty {
            return orderNo
        }

        return "#\(id)"
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var statusText: String {
        switch status?.lowercased() {
        case "pending":
            return "待處理"
        case "confirmed":
            return "已確認"
        case "preparing":
            return "製作中"
        case "completed":
            return "已完成"
        case "cancelled", "canceled":
            return "已取消"
        case let value? where !value.isEmpty:
            return value
        default:
            return "處理中"
        }
    }

    var createdAtText: String {
        guard let createdAt, !createdAt.isEmpty else {
            return "未提供訂購時間"
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fallbackISOFormatter = ISO8601DateFormatter()
        fallbackISOFormatter.formatOptions = [.withInternetDateTime]

        guard let date = isoFormatter.date(from: createdAt) ?? fallbackISOFormatter.date(from: createdAt) else {
            return createdAt
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "zh_Hant_TW")
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

extension OrderItem {
    var displayName: String {
        if let drinkName, !drinkName.isEmpty {
            return drinkName
        }

        return "飲品 #\(drinkID)"
    }

    var displaySubtotal: Int {
        subtotal ?? ((unitPrice ?? 0) * quantity)
    }
}
