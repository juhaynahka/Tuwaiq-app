//
//  LoginView.swift
//  TUWAIQ
//
//  Created by Tuwaiq.IT on 20/11/1446 AH.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct Country: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}

struct LoginView: View {
    @ObservedObject var userProfileVM: UserProfileViewModel
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country(name: "المملكة العربية السعودية", code: "+966", flag: "🇸🇦")
    @State private var isPickerPresented = false
    @State private var isOTPSent = false
    @State private var verificationID: String?
    @State private var otpCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.colorScheme) var colorScheme

    let countries = [
        Country(name: "المملكة العربية السعودية", code: "+966", flag: "🇸🇦"),
    ]
    
    private var backgroundColor: Color {
        return Color("BackgroundColor")
    }

    private var textColor: Color {
        return Color("TX2")
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("أدخل رقم هاتفك")
                    .font(.title2)
                    .foregroundColor(Color("TX2"))
                    .padding(.top, 40)

                Text("سيحتاج طُويق إلى التحقق من حسابك.")
                    .font(.body)
                    .foregroundColor(textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        HStack {
                            Text(selectedCountry.flag)
                            Text(selectedCountry.code)
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        CountryPickerView(countries: countries, selectedCountry: $selectedCountry)
                    }

                    TextField("رقم هاتفك", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        // 🔴 تحديد 10 أرقام وتحويل الأرقام العربية إلى إنجليزية
                        .onChange(of: phoneNumber) { _, _ in
                            let arabicToEnglish: [Character: Character] = [
                                "٠":"0", "١":"1", "٢":"2", "٣":"3", "٤":"4",
                                "٥":"5", "٦":"6", "٧":"7", "٨":"8", "٩":"9"
                            ]
                            
                            let converted = phoneNumber.compactMap { char -> Character? in
                                let englishChar = arabicToEnglish[char] ?? char
                                return englishChar.isNumber ? englishChar : nil
                            }
                            
                            phoneNumber = String(converted.prefix(10))
                        }
                }
                .padding(.horizontal)

                if isOTPSent {
                    SecureField("أدخل رمز التحقق", text: $otpCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Button(action: {
                        verifyOTP()
                    }) {
                        Text("تحقق")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                } else {
                    Button(action: {
                        sendOTP()
                    }) {
                        Text("التالي")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(phoneNumber.isEmpty ? Color.gray.opacity(0.5) : Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(phoneNumber.isEmpty)
                }

                // 🔵 زر تسجيل بالبريد الإلكتروني
                NavigationLink(destination: LoginView2()) {
                    Text("تسجيل بالبريد الإلكتروني")
                        .font(.footnote)
                        .foregroundColor(.green)
                        .padding(.top, 10)
                }

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
    }

    func sendOTP() {
        let fullPhoneNumber = "\(selectedCountry.code)\(phoneNumber)"
        
        Auth.auth().languageCode = "ar"
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            self.verificationID = verificationID
            self.isOTPSent = true
        }
    }

    func verifyOTP() {
        guard let verificationID = verificationID else {
            alertMessage = "حدث خطأ. حاول مرة أخرى."
            showAlert = true
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otpCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            alertMessage = "تم التحقق بنجاح!"
            showAlert = true
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CountryPickerView: View {
    let countries: [Country]
    @Binding var selectedCountry: Country
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(countries) { country in
                Button(action: {
                    selectedCountry = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                        Spacer()
                        Text(country.code)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("اختر الدولة")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// ✅ تعديل المعاينة لتجنب الخطأ – لا تحذفي هذا السطر
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userProfileVM: UserProfileViewModel()) // ✅ استبدلنا placeholder بكائن فعلي
            .environment(\.colorScheme, .light)

        LoginView(userProfileVM: UserProfileViewModel()) // ✅ نفس الشيء للوضع الداكن
            .environment(\.colorScheme, .dark)
    }
}
