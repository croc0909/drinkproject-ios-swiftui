import SwiftUI

struct DrinkRowView: View {
    let drink: Drink
    let addAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            drinkImage

            VStack(alignment: .leading, spacing: 8) {
                Text(drink.name)
                    .font(.system(size: 25, weight: .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(drink.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(alignment: .center) {
                    Text("$\(drink.price).00")
                        .font(.system(size: 21, weight: .regular))
                        .foregroundStyle(.orange)

                    Spacer(minLength: 12)

                    Button(action: addAction) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(.orange))
                    }
                    .buttonStyle(.plain)
                    .disabled(!drink.isAvailable)
                    .opacity(drink.isAvailable ? 1 : 0.45)
                    .accessibilityLabel("加入 \(drink.name)")
                }

                if !drink.isAvailable {
                    Text("暫停供應")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var drinkImage: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .clipped()
    }

    private var imageName: String {
        switch drink.id {
        case 1:
            return "BubbleTea"
        case 2:
            return "FourSeasons GreenTea"
        case 3:
            return "LemonWinterMelon"
        default:
            return drink.name
        }
    }
}

#Preview {
    DrinkRowView(drink: Drink.samples[0], addAction: {})
        .padding()
}
