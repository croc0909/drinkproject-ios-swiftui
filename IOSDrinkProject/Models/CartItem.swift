import Foundation

struct CartItem: Identifiable, Hashable {
    let id = UUID()
    let drink: Drink
    var quantity: Int

    var subtotal: Int {
        drink.price * quantity
    }
}
