//
//  HomeView.swift
//  TUWAIQ
//
//  Created by Tuwaiq.IT on 20/11/1446 AH.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ProfileEditorView: View {
    @ObservedObject var userProfileVM: UserProfileViewModel
    
    @State private var description: String = ""
    @State private var selectedLocation: String = "أبها"
    @State private var customLocation: String = ""
    @State private var isCustomLocation: Bool = false
    @State private var birthDate = Date()
    @State private var isBirthDatePickerVisible = false
    @State private var isImagePickerPresented = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isHeaderImage: Bool = false
    @State private var navigateToHome = false
    
    @Environment(\.colorScheme) var colorScheme
    
    let locations = [
        "أبها", "الدمام", "الرياض", "الطائف", "الظهران", "العاصمة المقدسة (مكة المكرمة)",
        "المدينة المنورة", "بريدة", "تبوك", "جازان", "جدة", "حائل",
        "خميس مشيط", "سكاكا", "عرعر", "عنّيزة", "نجران", "ينبع"
    ]
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("تعديل الملف الشخصي")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TX2"))
                    .padding(.top, 80)
                
                ZStack(alignment: .bottomTrailing) {
                    Button {
                        isHeaderImage = true
                        isImagePickerPresented = true
                    } label: {
                        if let image = userProfileVM.headerImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 165)
                                .cornerRadius(20)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(height: 165)
                                .cornerRadius(1)
                                .overlay(Text("إضافة صورة").foregroundColor(Color("TX2")))
                        }
                    }
                    
                    Button {
                        isHeaderImage = false
                        isImagePickerPresented = true
                    } label: {
                        ZStack {
                            if let image = userProfileVM.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color("TX2"))
                                    )
                            }
                        }
                    }
                    .offset(x: -20, y: 40)
                }
                
                Spacer().frame(height: 12)
                VStack(alignment: .trailing, spacing: 20) {
                    CustomTextField(label: "الاسم", text: $userProfileVM.name)
                    CustomTextField(label: "الوصف", text: $description)
                    
                    VStack(alignment: .trailing) {
                        Text("المدينة")
                            .foregroundColor(Color("TX2"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Picker(selection: $selectedLocation, label:
                                HStack {
                            Text(selectedLocation)
                                .foregroundColor(Color("TX2"))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.green)
                        }
                            .padding()
                            .background(Color("BackgroundColor"))
                            .cornerRadius(8)
                        ) {
                            ForEach(locations, id: \.self) { location in
                                Text(location).tag(location)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .trailing) {
                        Text("تاريخ الميلاد")
                            .foregroundColor(Color("TX2"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Button(action: {
                            isBirthDatePickerVisible.toggle()
                        }) {
                            HStack {
                                Text(formattedDate(birthDate))
                                    .foregroundColor(Color("TX2"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color("BackgroundColor"))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    saveProfile() // هنا تنادي دالة الحفظ
                    navigateToHome = true
                }) {
                    Text("ابدأ الآن!")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 70)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: isHeaderImage ? $userProfileVM.headerImage : $userProfileVM.profileImage,
                        sourceType: selectedSourceType)
        }
        .sheet(isPresented: $isBirthDatePickerVisible) {
            VStack {
                DatePicker("اختر تاريخ الميلاد", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                Button("إغلاق") {
                    isBirthDatePickerVisible = false
                }
                .padding()
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView(userProfileVM: userProfileVM)
        }
    }
    
    // دالة الحفظ مع رفع الصور وتخزينها في فايرستور
    func saveProfile() {
        guard let user = Auth.auth().currentUser else {
            print("المستخدم غير مسجل دخول")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        var data: [String: Any] = [
            "name": userProfileVM.name,
            "description": description,
            "location": isCustomLocation ? customLocation : selectedLocation,
            "birthDate": Timestamp(date: birthDate)
        ]

        let dispatchGroup = DispatchGroup()

        if let profileImage = userProfileVM.profileImage {
            dispatchGroup.enter()
            uploadImageToStorage(image: profileImage, path: "avatars/\(user.uid).jpg") { url in
                if let url = url {
                    data["avatarURL"] = url.absoluteString
                }
                dispatchGroup.leave()
            }
        }

        if let headerImage = userProfileVM.headerImage {
            dispatchGroup.enter()
            uploadImageToStorage(image: headerImage, path: "headers/\(user.uid).jpg") { url in
                if let url = url {
                    data["headerURL"] = url.absoluteString
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            userRef.setData(data, merge: true) { error in
                if let error = error {
                    print("خطأ في حفظ البيانات: \(error.localizedDescription)")
                } else {
                    print("تم حفظ الملف الشخصي بنجاح ✅")
                }
            }
        }
    }
    
    // دالة رفع الصورة إلى Firebase Storage
    func uploadImageToStorage(image: UIImage, path: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child(path)

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("فشل رفع الصورة: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("فشل الحصول على رابط الصورة: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                completion(url)
            }
        }
    }

    // دالة لتنسيق التاريخ بالعربية
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
}

// مكون حقل الإدخال المخصص
struct CustomTextField: View {
    var label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .trailing) {
            if !label.isEmpty {
                Text(label)
                    .foregroundColor(Color("TX2"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            TextField(placeholder.isEmpty ? "أدخل هنا" : placeholder, text: $text)
                .padding()
                .foregroundColor(Color("TX2"))
                .background(Color("BackgroundColor"))
                .cornerRadius(8)
                .multilineTextAlignment(.trailing)
        }
    }
}

// المعاينة
struct ProfileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditorView(userProfileVM: UserProfileViewModel())
            .environment(\.colorScheme, .light)

        ProfileEditorView(userProfileVM: UserProfileViewModel())
            .environment(\.colorScheme, .dark)
    }
}
