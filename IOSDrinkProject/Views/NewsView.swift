import SwiftUI

struct NewsView: View {
    @ObservedObject var viewModel: NewsViewModel

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "newspaper.fill")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.46))

            Text(viewModel.title)
                .font(.title.bold())

            Text("未來可以放新品上市、活動公告和門市通知。")
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
        NewsView(viewModel: NewsViewModel(title: "最新消息"))
    }
}
