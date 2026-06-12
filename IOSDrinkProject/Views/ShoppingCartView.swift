import SwiftUI

struct ShoppingCartView: View {
    @ObservedObject private var viewModel: DrinkListViewModel

    init(viewModel: DrinkListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            if viewModel.cartItems.isEmpty {
                ContentUnavailableView(
                    "購物車是空的",
                    systemImage: "cart",
                    description: Text("回到飲料列表，點選 + 加入想喝的飲品。")
                )
            } else {
                Section("購物車") {
                    ForEach(viewModel.cartItems) { item in
                        CartItemRowView(item: item)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeFromCart(item)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                    }
                }

                Section("訂單資訊") {
                    TextField("訂單備註", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)

                    HStack {
                        Text("總計")
                        Spacer()
                        Text("$\(viewModel.totalPrice)")
                            .fontWeight(.semibold)
                    }
                }

                Section {
                    Button {
                        Task {
                            await viewModel.submitOrder()
                        }
                    } label: {
                        Label("送出訂單", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("購物車")
        .alert("訂單已送出", isPresented: $viewModel.didSubmitOrder) {
            Button("完成", role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack {
        ShoppingCartView(viewModel: DrinkListViewModel())
    }
}
