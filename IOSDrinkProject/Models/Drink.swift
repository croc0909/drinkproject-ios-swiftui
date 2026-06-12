import Foundation

struct Drink: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Int
    let imageURL: URL?
    let category: String
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageURL = "image_url"
        case category
        case isAvailable = "is_available"
    }

    static let samples: [Drink] = [
        Drink(
            id: 1,
            name: "珍珠奶茶",
            description: "經典奶茶搭配 Q 彈珍珠。",
            price: 65,
            imageURL: nil,
            category: "人氣",
            isAvailable: true
        ),
        Drink(
            id: 2,
            name: "四季春青茶",
            description: "清香回甘，適合無糖或微糖。",
            price: 40,
            imageURL: nil,
            category: "茶飲",
            isAvailable: true
        ),
        Drink(
            id: 3,
            name: "檸檬冬瓜",
            description: "酸甜清爽，夏天很可以。",
            price: 55,
            imageURL: nil,
            category: "特調",
            isAvailable: true
        )
    ]
}
