import SwiftUI

struct NearbyStoresView: View {
    @ObservedObject var viewModel: NearbyStoresViewModel

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.46))

            Text(viewModel.title)
                .font(.title.bold())

            Text("未來可以接地圖定位，顯示最近門市和營業資訊。")
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
        NearbyStoresView(viewModel: NearbyStoresViewModel(title: "附近門市"))
    }
}
