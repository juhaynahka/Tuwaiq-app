//
//  ContactManager.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import Contacts
import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
}

class ContactManager: ObservableObject {
    @Published var contacts: [Contact] = []

    func requestPermissionAndFetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            if granted {
                self.fetchContacts(from: store)
            }
        }
    }

    private func fetchContacts(from store: CNContactStore) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let req = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        var results: [Contact] = []
        do {
            try store.enumerateContacts(with: req) { cn, _ in
                if let phone = cn.phoneNumbers.first?.value.stringValue {
                    let name = "\(cn.givenName) \(cn.familyName)"
                    results.append(Contact(name: name, phoneNumber: phone))
                }
            }
            DispatchQueue.main.async { self.contacts = results }
        } catch {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
}
