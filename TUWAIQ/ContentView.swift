import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn = false
    @StateObject var userProfileVM = UserProfileViewModel()
    @State private var checkingAuthState = true

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("T1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            VStack {
                if checkingAuthState {
                    // شاشة انتظار (Splash)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                } else {
                    if isUserLoggedIn {
                        // المستخدم مسجل دخول، اذهب للشاشة الرئيسية
                        HomeView(userProfileVM: userProfileVM)
                    } else {
                        // المستخدم غير مسجل دخول، اذهب لشاشة تسجيل الدخول
                        LoginView(userProfileVM: userProfileVM)
                    }
                }
            }
        }
        .onAppear {
            checkUserAuth()
        }
    }
    
    func checkUserAuth() {
        if let user = Auth.auth().currentUser {
            print("User is logged in: \(user.uid)")
            isUserLoggedIn = true
        } else {
            print("No user logged in")
            isUserLoggedIn = false
        }
        checkingAuthState = false
    }
}
