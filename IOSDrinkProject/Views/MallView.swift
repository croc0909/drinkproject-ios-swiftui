import SwiftUI

struct MallView: View {
    @ObservedObject var viewModel: MallViewModel

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.46))

            Text(viewModel.title)
                .font(.title.bold())

            Text("未來可以放優惠券、點數兌換和會員好禮。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.title)
    }
}

#Preview {
    NavigationStack {
        MallView(viewModel: MallViewModel(title: "商城兌換"))
    }
}
