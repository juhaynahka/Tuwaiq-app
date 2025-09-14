//
//  AddContactView.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import SwiftUI

struct AddContactView: View {
    @StateObject private var manager = ContactManager()
    @Environment(\.presentationMode) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(manager.contacts) { contact in
                    VStack(alignment: .leading) {
                        Text(contact.name)
                        Text(contact.phoneNumber)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("جهات الاتصال")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") {
                        dismiss.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                manager.requestPermissionAndFetch()
            }
        }
    }
}
