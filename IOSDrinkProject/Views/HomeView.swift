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
                .ignoresSafeArea()
                .overlay(alignment: .bottom) {
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
    @State private var currentImageIndex = 0

    private let homeImages = [
        "homeimage1",
        "homeimage2",
        "homeimage3",
        "homeimage4",
        "homeimage5"
    ]

    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    private let bottomBarClearance: CGFloat = 220

    var body: some View {
        GeometryReader { geometry in
            let backgroundWidth = geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
            let backgroundHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            let backgroundXOffset = (geometry.safeAreaInsets.trailing - geometry.safeAreaInsets.leading) / 2
            let backgroundYOffset = (geometry.safeAreaInsets.bottom - geometry.safeAreaInsets.top) / 2

            ZStack(alignment: .bottomLeading) {
                ZStack {
                    Image(homeImages[currentImageIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: backgroundWidth, height: backgroundHeight)
                        .clipped()
                        .id(currentImageIndex)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            )
                        )
                }
                .animation(.easeInOut(duration: 0.7), value: currentImageIndex)
                .offset(x: backgroundXOffset, y: backgroundYOffset)
                .ignoresSafeArea()
                .onReceive(timer) { _ in
                    currentImageIndex = (currentImageIndex + 1) % homeImages.count
                }

                LinearGradient(
                    colors: [
                        .black.opacity(0.04),
                        .black.opacity(0.18),
                        .black.opacity(0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: backgroundWidth, height: backgroundHeight)
                .offset(x: backgroundXOffset, y: backgroundYOffset)
                .clipped()

                VStack(alignment: .leading, spacing: 18) {
                    Text("Your\nHealthy\nStart")
                        .font(.system(size: 66, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 6)

                    Text("Ready to take control of your health? Just a few simple steps to begin.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineSpacing(4)
                        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 4)
                        .padding(.trailing, 24)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, bottomBarClearance)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
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
    private let selectedOrange = Color(red: 1.0, green: 0.53, blue: 0.16)

    var body: some View {
        HStack(spacing: 7) {
            ForEach(HomeTab.allCases) { tab in
                NavigationLink(value: tab) {
                    item(for: tab, isSelected: tab == .order)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(8)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule(style: .continuous)
                        .fill(.white.opacity(0.18))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(.white.opacity(0.72), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 10)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private func item(for tab: HomeTab, isSelected: Bool) -> some View {
        if isSelected {
            HStack(spacing: 8) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22, weight: .semibold))

                Text(tab.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .frame(width: 112, height: 62)
            .background {
                Capsule(style: .continuous)
                    .fill(selectedOrange)
                    .shadow(color: selectedOrange.opacity(0.34), radius: 10, x: 0, y: 5)
            }
        } else {
            Image(systemName: tab.systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.black.opacity(0.86))
                .frame(width: 56, height: 56)
                .background {
                    Circle()
                        .fill(.white.opacity(0.42))
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.38), lineWidth: 1)
                        }
                }
            }
    }
}

#Preview {
    HomeView()
}
