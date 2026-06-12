import SwiftUI

struct DrinkListView: View {
    @ObservedObject private var viewModel: DrinkListViewModel
    private let showsNavigationStack: Bool

    init(viewModel: DrinkListViewModel, showsNavigationStack: Bool = true) {
        self.viewModel = viewModel
        self.showsNavigationStack = showsNavigationStack
    }

    var body: some View {
        if showsNavigationStack {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            Section("飲品") {
                ForEach(viewModel.drinks) { drink in
                    DrinkRowView(drink: drink) {
                        viewModel.addToCart(drink)
                    }
                }
            }

            if !viewModel.cartItems.isEmpty {
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

                    TextField("訂單備註", text: $viewModel.note, axis: .vertical)

                    HStack {
                        Text("總計")
                        Spacer()
                        Text("$\(viewModel.totalPrice)")
                            .fontWeight(.semibold)
                    }

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
        .overlay {
            if viewModel.isLoading {
                ProgressView("載入飲品中")
            }
        }
        .navigationTitle("飲料訂購")
        .task {
            await viewModel.loadDrinks()
        }
        .alert("訂單已送出", isPresented: $viewModel.didSubmitOrder) {
            Button("完成", role: .cancel) {}
        }
    }
}

#Preview {
    DrinkListView(viewModel: DrinkListViewModel())
}
