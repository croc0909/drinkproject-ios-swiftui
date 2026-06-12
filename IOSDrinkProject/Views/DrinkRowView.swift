import SwiftUI

struct DrinkRowView: View {
    let drink: Drink
    let addAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title2)
                .foregroundStyle(.brown)
                .frame(width: 44, height: 44)
                .background(.brown.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(drink.name)
                        .font(.headline)
                    Spacer()
                    Text("$\(drink.price)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(drink.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(drink.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !drink.isAvailable {
                    Text("暫停供應")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Button(action: addAction) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(!drink.isAvailable)
            .accessibilityLabel("加入 \(drink.name)")
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DrinkRowView(drink: Drink.samples[0], addAction: {})
        .padding()
}
