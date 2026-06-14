import SwiftUI

struct MemberView: View {
    @ObservedObject var viewModel: MemberViewModel
    @State private var phone = ""
    @State private var name = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let user = viewModel.currentUser {
                    memberProfile(user)
                } else {
                    authForm
                }
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.title)
        .task {
            await viewModel.loadCurrentUserIfPossible()
        }
        .onDisappear {
            viewModel.clearTransientMessages()
        }
    }

    private var authForm: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(isRegistering ? "建立會員帳號" : "會員登入")
                    .font(.largeTitle.bold())

                Text(isRegistering ? "加入會員後可累積點數與查看訂單。" : "登入後可查看會員資料、優惠券與訂單紀錄。")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                TextField("手機號碼", text: $phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .textFieldStyle(.roundedBorder)

                if isRegistering {
                    TextField("姓名", text: $name)
                        .textContentType(.name)
                        .textFieldStyle(.roundedBorder)
                }

                SecureField("密碼", text: $password)
                    .textContentType(isRegistering ? .newPassword : .password)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task {
                        if isRegistering {
                            await viewModel.register(phone: phone, name: name, password: password)
                        } else {
                            await viewModel.login(phone: phone, password: password)
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        Text(isRegistering ? "註冊會員" : "登入")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }

            messageView

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRegistering.toggle()
                }
            } label: {
                Text(isRegistering ? "已經有會員帳號？前往登入" : "還不是會員？立即註冊")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderless)
        }
    }

    private func memberProfile(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("會員資料")
                    .font(.largeTitle.bold())

                Text("已登入，可以開始使用會員功能。")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(user.name, systemImage: "person.fill")
                Label(user.phone, systemImage: "phone.fill")
                Label("會員編號 \(user.id)", systemImage: "number")
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            messageView

            NavigationLink {
                OrderRecordsView(user: user)
            } label: {
                Label("訂單紀錄", systemImage: "receipt.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive) {
                viewModel.logout()
                password = ""
            } label: {
                Text("登出")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private var messageView: some View {
        switch viewModel.state {
        case .failed(let message):
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        case .signedIn(_, let message):
            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        case .signedOut, .checkingSession, .signingIn, .signingUp:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        MemberView(viewModel: MemberViewModel(title: "會員專區"))
    }
}
