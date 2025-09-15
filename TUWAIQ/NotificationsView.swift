//
//  NotificationsView.swift
//  TUWAIQ
//
//  Created by Assistant on 15/09/2025.
//

import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let icon: String
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [NotificationItem] = [
        .init(title: "رسالة جديدة", message: "وصلتك رسالة من طويق", date: Date(), icon: "message.fill"),
        .init(title: "تحديث الملف", message: "تم تحديث صورتك الشخصية", date: Date().addingTimeInterval(-3600), icon: "person.crop.circle"),
        .init(title: "قصة جديدة", message: "قام أحد أصدقائك بنشر قصة", date: Date().addingTimeInterval(-7200), icon: "sparkles")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.palmGreen, .dateBrown.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 42, height: 42)
                            Image(systemName: item.icon)
                                .foregroundColor(.textLight)
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.textDark)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Text(item.message)
                                .font(.subheadline)
                                .foregroundColor(.textDark.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        Spacer()
                        Text(item.date.formattedTime())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.desertSunsetGradient.ignoresSafeArea())
            .navigationTitle("الإشعارات")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textDark)
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationsView()
}


