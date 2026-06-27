import SwiftUI

struct CartItemRowView: View {
    let item: CartItem
    let decreaseAction: () -> Void
    let increaseAction: () -> Void
    let removeAction: () -> Void
    private let accentColor = Color.orange
    private let textColor = Color(red: 0.16, green: 0.12, blue: 0.09)

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 112)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .clipped()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.drink.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(textColor)
                            .lineLimit(1)

                        Text(item.drink.description)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button(action: removeAction) {
                        Image(systemName: "trash")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("刪除 \(item.drink.name)")
                }

                Spacer(minLength: 0)

                HStack(alignment: .center) {
                    Text("$\(item.subtotal).00")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(accentColor)

                    Spacer()

                    quantityButton(systemName: "minus", action: decreaseAction)

                    Text("\(item.quantity)")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(textColor)
                        .frame(width: 28)

                    quantityButton(systemName: "plus", action: increaseAction)
                }
            }
        }
        .padding(16)
        .frame(minHeight: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.orange.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: Color.orange.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private func quantityButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.orange.opacity(0.10)))
                .overlay {
                    Circle().stroke(Color.orange.opacity(0.20), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemName == "plus" ? "增加數量" : "減少數量")
    }

    private var imageName: String {
        switch item.drink.id {
        case 1:
            return "BubbleTea"
        case 2:
            return "FourSeasons GreenTea"
        case 3:
            return "LemonWinterMelon"
        default:
            return item.drink.name
        }
    }
}

#Preview {
    CartItemRowView(
        item: CartItem(drink: Drink.samples[0], quantity: 2),
        decreaseAction: {},
        increaseAction: {},
        removeAction: {}
    )
    .padding()
    .background(Color(red: 1.0, green: 0.97, blue: 0.92))
}
