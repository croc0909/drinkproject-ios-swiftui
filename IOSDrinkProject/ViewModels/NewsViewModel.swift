import Foundation

final class NewsViewModel: ObservableObject {
    @Published var title: String

    init(title: String) {
        self.title = title
    }
}
