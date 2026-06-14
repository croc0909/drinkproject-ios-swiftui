import SwiftUI

struct OrderRecordsView: View {
    @StateObject private var viewModel: OrderRecordsViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: OrderRecordsViewModel(user: user))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                ProgressView("載入訂單紀錄中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.orders.isEmpty {
                ContentUnavailableView {
                    Label("無法取得訂單紀錄", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("重新載入") {
                        Task {
                            await viewModel.loadOrders()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if viewModel.orders.isEmpty {
                ContentUnavailableView {
                    Label("尚無訂單紀錄", systemImage: "receipt")
                } description: {
                    Text("完成點餐後，訂單會顯示在這裡。")
                }
            } else {
                List {
                    ForEach(viewModel.orders) { order in
                        OrderRecordRow(order: order)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refreshOrders()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("訂單紀錄")
        .task {
            await viewModel.loadOrders()
        }
    }
}

private struct OrderRecordRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("訂單編號 \(order.displayOrderNo)")
                        .font(.headline)

                    Text(order.createdAtText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(order.statusText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(order.statusColor.opacity(0.14))
                    .foregroundStyle(order.statusColor)
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                Label("共 \(order.totalQuantity) 件商品", systemImage: "cup.and.saucer.fill")
                Label("$\(order.totalPrice)", systemImage: "dollarsign.circle.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            NavigationLink {
                OrderDetailsView(order: order)
            } label: {
                Label("查看明細", systemImage: "doc.text.magnifyingglass")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.vertical, 6)
    }
}

private extension Order {
    var statusColor: Color {
        switch status?.lowercased() {
        case "completed":
            return .green
        case "cancelled", "canceled":
            return .red
        case "confirmed", "preparing":
            return .orange
        default:
            return .blue
        }
    }
}

#Preview {
    NavigationStack {
        OrderRecordsView(user: User(id: 1, phone: "0912345678", name: "測試會員"))
    }
}
