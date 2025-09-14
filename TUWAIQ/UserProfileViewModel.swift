//
//  UserProfileViewModel.swift
//  طويق
//
//  Created by Tuwaiq.IT on 30/01/1447 AH.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class UserProfileViewModel: ObservableObject {
    @Published var name: String = "طويق"
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var birthDate: Date? = nil

    @Published var profileImage: UIImage? = nil
    @Published var headerImage: UIImage? = nil

    func loadUserProfile() {
        guard let user = Auth.auth().currentUser else {
            print("❌ لا يوجد مستخدم مسجل الدخول")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ فشل في جلب بيانات المستخدم: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("❌ لا توجد بيانات للمستخدم")
                return
            }

            DispatchQueue.main.async {
                self.name = data["name"] as? String ?? "طويق"
                self.description = data["description"] as? String ?? ""
                self.location = data["location"] as? String ?? ""

                if let timestamp = data["birthDate"] as? Timestamp {
                    self.birthDate = timestamp.dateValue()
                }

                if let avatarURL = data["avatarURL"] as? String {
                    self.loadImage(from: avatarURL) { image in
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                }

                if let headerURL = data["headerURL"] as? String {
                    self.loadImage(from: headerURL) { image in
                        DispatchQueue.main.async {
                            self.headerImage = image
                        }
                    }
                }
            }
        }
    }

    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ فشل تحميل الصورة من الرابط: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
