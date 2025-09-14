//
//  ChatView.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import SwiftUI

struct MessageModel: Identifiable {
    let id = UUID()
    let text: String
    let isSender: Bool
    let timestamp: Date
}

struct ChatView: View {
    @Binding var hideTabBar: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var messages: [MessageModel] = [
        MessageModel(text: "السلام عليكم!", isSender: false, timestamp: Date().addingTimeInterval(-300)),
        MessageModel(text: "وعليكم السلام، كيف الحال؟", isSender: true, timestamp: Date().addingTimeInterval(-250))
    ]
    @State private var newMessage: String = ""
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header مع زر الاتصال
            HStack(spacing: 12) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.0))
                        .font(.title3)
                }
                
                Button {
                    // Add action if needed
                } label: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .overlay(Text("ط").foregroundColor(.white).font(.headline))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("طويق")
                        .font(.headline)
                    Text("آخر ظهور قبل 5 دقائق")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    print("بدأ الاتصال الصوتي")
                }) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.0))
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
                .background(Color(.systemGroupedBackground))
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // Input Area مع زر المايك وزر الإرسال جنب بعض
            HStack(spacing: 11) {
                TextField("اكتب رسالة...", text: $newMessage)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .frame(minHeight: 40)
                
                Button(action: {
                    print("زر المايك انضغط - هنا تضيفين تسجيل الصوت")
                }) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .padding(11)
                        .background(Color(red: 0.0, green: 0.4, blue: 0.0))
                        .clipShape(Circle())
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "location.north")
                        .foregroundColor(.white)
                        .padding(11)
                        .background(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color(red: 0.0, green: 0.4, blue: 0.0))
                        .clipShape(Circle())
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .animation(.easeInOut(duration: 0.2), value: newMessage)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .padding(.bottom, keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            
        }
        .navigationBarHidden(true)
        .onAppear {
            hideTabBar = true
            addKeyboardObservers()
        }
        .onDisappear {
            hideTabBar = false
            removeKeyboardObservers()
        }
    }
    
    // MARK: - Keyboard Observers
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let screenHeight = UIScreen.main.bounds.height
                let safeAreaBottom = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?
                    .safeAreaInsets.bottom ?? 0
                let keyboardTop = frame.origin.y
                let keyboardHeight = screenHeight - keyboardTop - safeAreaBottom
                self.keyboardHeight = max(0, keyboardHeight)
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Send Message
    func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let message = MessageModel(text: trimmed, isSender: true, timestamp: Date())
        messages.append(message)
        newMessage = ""
    }
}

struct MessageBubble: View {
    let message: MessageModel
    
    var body: some View {
        HStack {
            if message.isSender { Spacer() }
            
            VStack(alignment: message.isSender ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isSender ? Color(red: 0.0, green: 0.4, blue: 0.0) : Color.gray.opacity(0.2))
                    .foregroundColor(message.isSender ? .white : .primary)
                    .cornerRadius(16)
                    .shadow(color: message.isSender ? Color.green.opacity(0.3) : Color.gray.opacity(0.15), radius: 4, x: 0, y: 2)
                
                Text(formatDate(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.isSender ? .trailing : .leading, 8)
            }
            .frame(maxWidth: 250, alignment: message.isSender ? .trailing : .leading)
            
            if !message.isSender { Spacer() }
        }
        .id(message.id)
        .padding(message.isSender ? .leading : .trailing, 40)
        .padding(.horizontal, 8)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// ✅ Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(hideTabBar: .constant(false))
            .environment(\.colorScheme, .light)
        
        ChatView(hideTabBar: .constant(false))
            .environment(\.colorScheme, .dark)
    }
}

