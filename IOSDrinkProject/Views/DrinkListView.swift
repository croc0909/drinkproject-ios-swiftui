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
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 22, bottom: 8, trailing: 22))
            }

            ForEach(viewModel.drinks) { drink in
                DrinkRowView(drink: drink) {
                    viewModel.addToCart(drink)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 28))
                .listRowBackground(Color.white)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .overlay {
            if viewModel.isLoading {
                ProgressView("載入飲品中")
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.cartItems.isEmpty {
                NavigationLink {
                    ShoppingCartView(viewModel: viewModel)
                } label: {
                    HStack {
                        Label("購物車", systemImage: "cart.fill")
                            .fontWeight(.semibold)

                        Spacer()

                        Text("\(viewModel.totalQuantity) 項・$\(viewModel.totalPrice)")
                            .fontWeight(.semibold)

                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(.bar)
            }
        }
        .navigationTitle("飲料訂購")
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadDrinks()
        }
    }
}

#Preview {
    DrinkListView(viewModel: DrinkListViewModel())
}
