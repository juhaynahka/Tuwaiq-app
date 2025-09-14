//
//  LoginView2.swift
//  TUWAIQ
//
//  Created by Tuwaiq.IT on 20/11/1446 AH.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView2: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false

    @Environment(\.colorScheme) var colorScheme

    private var backgroundColor: Color {
        return Color("BackgroundColor")
    }

    private var textColor: Color {
        return Color("TX2")
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("أدخل بريدك الإلكتروني")
                    .font(.title2)
                    .foregroundColor(textColor)
                    .padding(.top, 40)

                Text("سيحتاج طُويق إلى التحقق من حسابك.")
                    .font(.body)
                    .foregroundColor(textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    TextField("بريدك الإلكتروني", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    SecureField("كلمة المرور", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    loginWithEmail()
                }) {
                    Text("تسجيل الدخول")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((email.isEmpty || password.isEmpty) ? Color.gray.opacity(0.5) : Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(email.isEmpty || password.isEmpty)

                Spacer()
            }
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .ignoresSafeArea()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("خطأ"), message: Text(alertMessage), dismissButton: .default(Text("حسنًا")))
            }
            .onTapGesture {
                dismissKeyboard()
            }
        }
        // ✅ يعرض HomeView بملء الشاشة عند تسجيل الدخول بنجاح
        .fullScreenCover(isPresented: $isLoggedIn) {
            ProfileEditorView(userProfileVM: UserProfileViewModel())        }
    }

    func loginWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



struct LoginView2_Previews: PreviewProvider {
    static var previews: some View {
        LoginView2()
            .environment(\.colorScheme, .light)
        LoginView2()
            .environment(\.colorScheme, .dark)
    }
}
