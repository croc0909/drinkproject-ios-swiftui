import SwiftUI

struct HomeView: View {
    @StateObject private var drinkListViewModel = DrinkListViewModel()
    @StateObject private var mallViewModel = MallViewModel(title: "商城兌換")
    @StateObject private var newsViewModel = NewsViewModel(title: "最新消息")
    @StateObject private var nearbyStoresViewModel = NearbyStoresViewModel(title: "附近門市")
    @StateObject private var memberViewModel = MemberViewModel(title: "會員專區")

    var body: some View {
        NavigationStack {
            HomeLandingView()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    HomeShortcutBar()
                }
                .navigationDestination(for: HomeTab.self) { tab in
                    destination(for: tab)
                }
        }
    }

    @ViewBuilder
    private func destination(for tab: HomeTab) -> some View {
        switch tab {
        case .exchange:
            MallView(viewModel: mallViewModel)
        case .news:
            NewsView(viewModel: newsViewModel)
        case .order:
            DrinkListView(viewModel: drinkListViewModel, showsNavigationStack: false)
        case .nearby:
            NearbyStoresView(viewModel: nearbyStoresViewModel)
        case .member:
            MemberView(viewModel: memberViewModel)
        }
    }
}

private struct HomeLandingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("歡迎回來")
                    .font(.largeTitle.bold())

                Text("選擇下方功能，開始兌換、查看消息、點餐或管理會員資料。")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 86, weight: .semibold))
                .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.46))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 44)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("首頁")
    }
}

private enum HomeTab: CaseIterable, Identifiable {
    case exchange
    case news
    case order
    case nearby
    case member

    var id: Self { self }

    var title: String {
        switch self {
        case .exchange:
            return "商城兌換"
        case .news:
            return "最新消息"
        case .order:
            return "點餐"
        case .nearby:
            return "附近門市"
        case .member:
            return "會員專區"
        }
    }

    var systemImage: String {
        switch self {
        case .exchange:
            return "storefront.fill"
        case .news:
            return "newspaper.fill"
        case .order:
            return "bag.fill"
        case .nearby:
            return "mappin.and.ellipse"
        case .member:
            return "person.crop.circle"
        }
    }
}

private struct HomeShortcutBar: View {
    private let brandBlue = Color(red: 0.08, green: 0.20, blue: 0.46)
    private let accentYellow = Color(red: 1.0, green: 0.76, blue: 0.06)

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(HomeTab.allCases) { tab in
                NavigationLink(value: tab) {
                    item(for: tab)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private func item(for tab: HomeTab) -> some View {
        if tab == .order {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(brandBlue)
                        .frame(width: 84, height: 84)
                        .offset(y: 4)

                    Circle()
                        .fill(accentYellow)
                        .frame(width: 72, height: 72)
                        .shadow(color: accentYellow.opacity(0.35), radius: 10, x: 0, y: 5)

                    Image(systemName: tab.systemImage)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .offset(y: -30)
                .frame(height: 54)

                Text(tab.title)
                    .font(.headline)
                    .foregroundStyle(accentYellow)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 27, weight: .semibold))
                    .frame(height: 30)

                Text(tab.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(brandBlue)
            .padding(.top, 18)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    HomeView()
}
