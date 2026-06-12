import Foundation

final class MallViewModel: ObservableObject {
    @Published var title: String

    init(title: String) {
        self.title = title
    }
}
