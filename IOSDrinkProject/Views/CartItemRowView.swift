import SwiftUI

struct CartItemRowView: View {
    let item: CartItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.drink.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("數量 \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("$\(item.subtotal)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    CartItemRowView(item: CartItem(drink: Drink.samples[0], quantity: 2))
        .padding()
}
