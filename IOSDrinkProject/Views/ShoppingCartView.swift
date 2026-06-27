import SwiftUI

struct ShoppingCartView: View {
    @ObservedObject private var viewModel: DrinkListViewModel
    private let backgroundColor = Color(red: 1.0, green: 0.97, blue: 0.92)
    private let cardColor = Color.white

    init(viewModel: DrinkListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if viewModel.cartItems.isEmpty {
                ContentUnavailableView(
                    "購物車是空的",
                    systemImage: "cart",
                    description: Text("回到飲料列表，點選 + 加入想喝的飲品。")
                )
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.cartItems) { item in
                    CartItemRowView(
                        item: item,
                        decreaseAction: {
                            viewModel.decreaseQuantity(for: item)
                        },
                        increaseAction: {
                            viewModel.increaseQuantity(for: item)
                        },
                        removeAction: {
                            viewModel.removeFromCart(item)
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                    .listRowBackground(Color.clear)
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
                .foregroundStyle(.primary)
                .listRowBackground(cardColor)

                Section {
                    Button {
                        Task {
                            await viewModel.submitOrder()
                        }
                    } label: {
                        Label("送出訂單", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 10, leading: 18, bottom: 14, trailing: 18))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(backgroundColor)
        .navigationTitle("購物車")
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(.orange)
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
