import Foundation
import OSLog

enum MemberViewState {
    case signedOut
    case checkingSession
    case signingIn
    case signingUp
    case signedIn(User, message: String?)
    case failed(String)

    var currentUser: User? {
        if case .signedIn(let user, _) = self {
            return user
        }

        return nil
    }

    var isLoading: Bool {
        switch self {
        case .checkingSession, .signingIn, .signingUp:
            return true
        case .signedOut, .signedIn, .failed:
            return false
        }
    }

    var message: String? {
        switch self {
        case .signedIn(_, let message):
            return message
        case .failed(let message):
            return message
        case .signedOut, .checkingSession, .signingIn, .signingUp:
            return nil
        }
    }
}

@MainActor
final class MemberViewModel: ObservableObject {
    @Published var title: String
    @Published private(set) var state: MemberViewState = .signedOut

    private let apiClient: APIClient
    private let tokenStore: UserDefaults
    private let tokenKey = "authToken"
    private let logger = Logger(subsystem: "com.andylin.IOSDrinkProject", category: "MemberViewModel")

    var currentUser: User? {
        state.currentUser
    }

    var isLoading: Bool {
        state.isLoading
    }

    var message: String? {
        state.message
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    init(
        apiClient: APIClient = .shared,
        tokenStore: UserDefaults = .standard,
        title: String
    ) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
        self.title = title
        logger.info("[Member Flow] ViewModel initialized for title: \(title, privacy: .public)")
    }

    func register(phone: String, name: String, password: String) async {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        logger.info("[Member Flow] Register tapped -> phone: \(trimmedPhone, privacy: .private(mask: .hash)), name: \(trimmedName, privacy: .private(mask: .hash)), password empty: \(password.isEmpty, privacy: .public)")

        await performAuthAction(loadingState: .signingUp, successMessage: "註冊成功") {
            try await apiClient.register(
                phone: trimmedPhone,
                name: trimmedName,
                password: password
            )
        }
    }

    func login(phone: String, password: String) async {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        logger.info("[Member Flow] Login tapped -> phone: \(trimmedPhone, privacy: .private(mask: .hash)), password empty: \(password.isEmpty, privacy: .public)")

        await performAuthAction(loadingState: .signingIn, successMessage: "登入成功") {
            try await apiClient.login(
                phone: trimmedPhone,
                password: password
            )
        }
    }

    func loadCurrentUserIfPossible() async {
        logger.info("[Member Flow] loadCurrentUserIfPossible started")

        if currentUser != nil {
            logger.info("[Member Flow] Skip /api/me because currentUser already exists")
            return
        }

        guard let token = tokenStore.string(forKey: tokenKey) else {
            logger.info("[Member Flow] No saved token, showing auth form")
            transition(to: .signedOut, reason: "no saved token")
            return
        }

        logger.info("[Member Flow] Saved token found, calling /api/me")
        transition(to: .checkingSession, reason: "fetch current user")

        do {
            let user = try await apiClient.fetchMe(token: token)
            logger.info("[Member Flow] /api/me success -> user id \(user.id, privacy: .public)")
            transition(to: .signedIn(user, message: "已取得會員資料"), reason: "fetch current user success")
        } catch {
            tokenStore.removeObject(forKey: tokenKey)
            logger.error("[Member Flow] /api/me failed, token removed -> \(error.localizedDescription, privacy: .public)")
            transition(to: .signedOut, reason: "saved session expired")
        }
    }

    func logout() {
        logger.info("[Member Flow] Logout tapped -> removing saved token and clearing current user")
        tokenStore.removeObject(forKey: tokenKey)
        transition(to: .signedOut, reason: "logout")
        logger.info("[Member Flow] Logout finished")
    }

    func clearTransientMessages() {
        switch state {
        case .failed:
            transition(to: .signedOut, reason: "clear failed message")
        case .signedIn(let user, let message) where message != nil:
            transition(to: .signedIn(user, message: nil), reason: "clear signed-in message")
        case .signedOut, .checkingSession, .signingIn, .signingUp, .signedIn:
            logger.info("[Member Flow] clearTransientMessages skipped because current state has no transient message")
        }
    }

    private func performAuthAction(
        loadingState: MemberViewState,
        successMessage: String,
        action: () async throws -> AuthResponse
    ) async {
        logger.info("[Member Flow] Auth action started -> \(successMessage, privacy: .public)")
        transition(to: loadingState, reason: "auth action started")

        do {
            logger.info("[Member Flow] Calling APIClient auth action")
            let response = try await action()
            logger.info("[Member Flow] Auth API returned -> user id \(response.user.id, privacy: .public), token empty: \(response.token.isEmpty, privacy: .public)")

            tokenStore.set(response.token, forKey: tokenKey)
            logger.info("[Member Flow] Token saved to UserDefaults key: \(self.tokenKey, privacy: .public)")

            transition(to: .signedIn(response.user, message: successMessage), reason: "auth action success")
            logger.info("[Member Flow] Current user updated -> user id \(response.user.id, privacy: .public)")
        } catch {
            logger.error("[Member Flow] Auth action failed -> \(error.localizedDescription, privacy: .public)")
            transition(to: .failed(error.localizedDescription), reason: "auth action failed")
        }
    }

    private func transition(to newState: MemberViewState, reason: String) {
        state = newState
        logger.info("[Member Flow] state -> \(self.stateDescription(newState), privacy: .public), reason: \(reason, privacy: .public)")
    }

    private func stateDescription(_ state: MemberViewState) -> String {
        switch state {
        case .signedOut:
            return "signedOut"
        case .checkingSession:
            return "checkingSession"
        case .signingIn:
            return "signingIn"
        case .signingUp:
            return "signingUp"
        case .signedIn(let user, let message):
            return "signedIn(userID: \(user.id), hasMessage: \(message != nil))"
        case .failed(let message):
            return "failed(message: \(message))"
        }
    }
}
