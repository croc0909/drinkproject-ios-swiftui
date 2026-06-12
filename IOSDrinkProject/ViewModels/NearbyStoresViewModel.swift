import Foundation

final class NearbyStoresViewModel: ObservableObject {
    @Published var title: String

    init(title: String) {
        self.title = title
    }
}
