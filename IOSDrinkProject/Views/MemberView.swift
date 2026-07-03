import SwiftUI

struct MemberView: View {
    @ObservedObject var viewModel: MemberViewModel

    @State private var phone = ""
    @State private var name = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var showsPassword = false
    @State private var showsLogoutConfirmation = false

    private let brandOrange = Color(red: 1.0, green: 0.53, blue: 0.16)
    private let warmBackground = Color(red: 1.0, green: 0.97, blue: 0.92)
    private let softOrange = Color(red: 1.0, green: 0.93, blue: 0.84)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let user = viewModel.currentUser {
                    memberProfile(user)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    authForm
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 36)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(warmBackground.ignoresSafeArea())
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(warmBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(brandOrange)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isLoggedIn)
        .task {
            await viewModel.loadCurrentUserIfPossible()
        }
        .onDisappear {
            viewModel.clearTransientMessages()
        }
        .alert("確定要登出嗎？", isPresented: $showsLogoutConfirmation) {
            Button("取消", role: .cancel) {}
            Button("登出", role: .destructive) {
                viewModel.logout()
                password = ""
            }
        } message: {
            Text("下次使用會員功能時，需要重新登入。")
        }
    }

    private var authForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            welcomeHeader

            authModePicker

            VStack(spacing: 16) {
                memberField(
                    title: "手機號碼",
                    systemImage: "iphone",
                    placeholder: "請輸入手機號碼"
                ) {
                    TextField("請輸入手機號碼", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }

                if isRegistering {
                    memberField(
                        title: "姓名",
                        systemImage: "person",
                        placeholder: "請輸入姓名"
                    ) {
                        TextField("請輸入姓名", text: $name)
                            .textContentType(.name)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                passwordField

                Button(action: submitAuth) {
                    HStack(spacing: 10) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: isRegistering ? "person.badge.plus" : "arrow.right")
                                .font(.body.weight(.bold))
                        }

                        Text(buttonTitle)
                            .font(.headline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(canSubmit ? brandOrange : brandOrange.opacity(0.45))
                    )
                    .shadow(
                        color: canSubmit ? brandOrange.opacity(0.22) : .clear,
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit || viewModel.isLoading)
                .accessibilityHint(canSubmit ? "" : "請完整填寫會員資料")
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(brandOrange.opacity(0.14), lineWidth: 1)
                    }
                    .shadow(color: brandOrange.opacity(0.08), radius: 20, x: 0, y: 10)
            }

            messageView

            HStack(spacing: 6) {
                Text(isRegistering ? "已經是會員？" : "還不是會員？")
                    .foregroundStyle(.secondary)

                Button(isRegistering ? "前往登入" : "立即註冊") {
                    switchAuthMode()
                }
                .fontWeight(.bold)
                .foregroundStyle(brandOrange)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
        }
    }

    private var welcomeHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(softOrange)

                Image(systemName: isRegistering ? "person.badge.plus" : "cup.and.saucer.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(brandOrange)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 5) {
                Text(isRegistering ? "建立會員帳號" : "歡迎回來")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Text(isRegistering ? "加入會員，讓每一杯都有回饋。" : "登入後繼續你的飲品日常。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var authModePicker: some View {
        HStack(spacing: 6) {
            authModeButton(title: "登入", isSelected: !isRegistering) {
                guard isRegistering else { return }
                switchAuthMode()
            }

            authModeButton(title: "註冊", isSelected: isRegistering) {
                guard !isRegistering else { return }
                switchAuthMode()
            }
        }
        .padding(5)
        .background(
            Capsule(style: .continuous)
                .fill(brandOrange.opacity(0.10))
        )
    }

    private func authModeButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : brandOrange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(brandOrange)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func memberField<Content: View>(
        title: String,
        systemImage: String,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(warmBackground.opacity(0.72))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(brandOrange.opacity(0.12), lineWidth: 1)
                        }
                )
                .accessibilityLabel(title)
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("密碼", systemImage: "lock")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Group {
                    if showsPassword {
                        TextField("請輸入密碼", text: $password)
                    } else {
                        SecureField("請輸入密碼", text: $password)
                    }
                }
                .textContentType(isRegistering ? .newPassword : .password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    showsPassword.toggle()
                } label: {
                    Image(systemName: showsPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showsPassword ? "隱藏密碼" : "顯示密碼")
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(warmBackground.opacity(0.72))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(brandOrange.opacity(0.12), lineWidth: 1)
                    }
            )
        }
    }

    private func memberProfile(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("嗨，\(user.name)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))

                        Text("今天想喝點什麼？")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.84))
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.20))

                        Image(systemName: "person.fill")
                            .font(.system(size: 27, weight: .semibold))
                    }
                    .frame(width: 60, height: 60)
                }

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("會員編號 \(user.id)")
                }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.18), in: Capsule())
            }
            .foregroundStyle(.white)
            .padding(22)
            .background {
                LinearGradient(
                    colors: [brandOrange, Color(red: 1.0, green: 0.39, blue: 0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: brandOrange.opacity(0.24), radius: 18, x: 0, y: 10)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("會員資料")
                    .font(.headline.weight(.bold))

                profileRow(title: "姓名", value: user.name, systemImage: "person")
                Divider()
                profileRow(title: "手機號碼", value: user.phone, systemImage: "iphone")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .shadow(color: brandOrange.opacity(0.07), radius: 16, x: 0, y: 8)
            )

            messageView

            NavigationLink {
                OrderRecordsView(user: user)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "receipt.fill")
                    Text("查看訂單紀錄")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(brandOrange)
                )
                .shadow(color: brandOrange.opacity(0.20), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            Button {
                showsLogoutConfirmation = true
            } label: {
                Text("登出帳號")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(brandOrange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(brandOrange.opacity(0.30), lineWidth: 1)
                            }
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func profileRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(brandOrange)
                .frame(width: 38, height: 38)
                .background(softOrange, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.body.weight(.semibold))
            }
        }
    }

    @ViewBuilder
    private var messageView: some View {
        switch viewModel.state {
        case .failed(let message):
            statusMessage(message, systemImage: "exclamationmark.circle.fill", color: .red)
        case .signedIn(_, let message):
            if let message {
                statusMessage(message, systemImage: "checkmark.circle.fill", color: .green)
            }
        case .signedOut, .checkingSession, .signingIn, .signingUp:
            EmptyView()
        }
    }

    private func statusMessage(_ message: String, systemImage: String, color: Color) -> some View {
        Label(message, systemImage: systemImage)
            .font(.footnote.weight(.medium))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var buttonTitle: String {
        if viewModel.isLoading {
            return isRegistering ? "建立帳號中…" : "登入中…"
        }

        return isRegistering ? "建立會員帳號" : "登入會員"
    }

    private var canSubmit: Bool {
        let hasPhone = !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasPhone && !password.isEmpty && (!isRegistering || hasName)
    }

    private func switchAuthMode() {
        withAnimation(.easeInOut(duration: 0.22)) {
            isRegistering.toggle()
            showsPassword = false
            viewModel.clearTransientMessages()
        }
    }

    private func submitAuth() {
        Task {
            if isRegistering {
                await viewModel.register(phone: phone, name: name, password: password)
            } else {
                await viewModel.login(phone: phone, password: password)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MemberView(viewModel: MemberViewModel(title: "會員專區"))
    }
}
