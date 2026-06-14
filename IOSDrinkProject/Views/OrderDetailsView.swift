import SwiftUI

struct OrderDetailsView: View {
    let order: Order

    var body: some View {
        List {
            Section("訂單資訊") {
                detailRow(title: "訂單編號", value: order.displayOrderNo)
                detailRow(title: "訂單狀態", value: order.statusText)
                detailRow(title: "訂購時間", value: order.createdAtText)
                detailRow(title: "訂購人", value: order.customerName)
                detailRow(title: "手機號碼", value: order.phone)
            }

            Section("商品明細") {
                ForEach(Array(order.items.enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.displayName)
                                .font(.headline)

                            Spacer()

                            Text("x\(item.quantity)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(item.sweetness) / \(item.iceLevel)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            if let unitPrice = item.unitPrice {
                                Text("單價 $\(unitPrice)")
                            }

                            Spacer()

                            Text("小計 $\(item.displaySubtotal)")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                }
            }

            Section {
                HStack {
                    Text("共 \(order.totalQuantity) 件商品")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("總計 $\(order.totalPrice)")
                        .font(.title3.bold())
                }
            }
        }
        .navigationTitle("訂單明細")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailsView(
            order: Order(
                id: 101,
                orderNo: "ORD202606140001",
                customerName: "測試會員",
                phone: "0912345678",
                items: [
                    OrderItem(
                        drinkID: 1,
                        drinkName: "珍珠奶茶",
                        quantity: 2,
                        sweetness: "半糖",
                        iceLevel: "少冰",
                        unitPrice: 60,
                        subtotal: 120
                    )
                ],
                totalPrice: 120,
                status: "pending",
                createdAt: "2026-06-13T12:00:00Z"
            )
        )
    }
}
