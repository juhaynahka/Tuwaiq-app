//
//  ChatsView.swift
//  طويق
//
//  Created by Tuwaiq.IT on 12/02/1447 AH.
//

import SwiftUI

struct ChatItem: Identifiable {
    let id: String
    let name: String
    let lastMessage: String
    let timestamp: Date
    let profileImageURL: String?
}

struct ChatsView: View {
    
    @Binding var hideTabBar: Bool
    
    @State var chats: [ChatItem] = [
        ChatItem(id: "1", name: "طويق", lastMessage: "كيف حالك؟", timestamp: Date(), profileImageURL: nil),
        ChatItem(id: "2", name: "أحمد", lastMessage: "تمام الحمدلله", timestamp: Date().addingTimeInterval(-3600), profileImageURL: nil),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if chats.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color.gray.opacity(0.4))
                        Text("لا توجد دردشات")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .font(.headline)
                    }
                    Spacer()
                } else {
                    List(chats) { chat in
                        NavigationLink(destination: ChatView(hideTabBar: $hideTabBar)) {
                            ChatRow(chat: chat)
                        }

                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("الدردشات")
            .background(Color.black.ignoresSafeArea())
        }
    }
}

struct ChatRow: View {
    let chat: ChatItem
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageURL = chat.profileImageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 55, height: 55)
                    .overlay(
                        Text(chat.name.prefix(1))
                            .font(.title2)
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(formatDate(chat.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}



struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView(hideTabBar: .constant(false))
            .environment(\.colorScheme, .light)
        
        ChatsView(hideTabBar: .constant(false))
            .environment(\.colorScheme, .dark)
    }
}
