//
//  HomeView.swift
//  طويق
//
//  Created by Tuwaiq.IT on 22/11/1446 AH.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct HomeView: View {
    @ObservedObject var userProfileVM: UserProfileViewModel
    
    @State private var selectedTab: Tab = .home
    @State private var selectedSubTab: SubTab = .posts
    @State private var showEditProfile = false
    @State private var showUserProfile = false
    @State private var hideTabBar: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    enum Tab {
        case stories, home, chats
    }
    
    enum SubTab {
        case posts, stories
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .trailing) {
                

                
                if selectedTab == .home {
                    HStack {
                        Button(action: { showEditProfile.toggle() }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 25))
                                .foregroundColor(Color("TX2"))
                                .padding(.leading, 20)
                        }
                        
                        Spacer()
                        
                        Text(tabTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TX2"))
                            .padding(.top, 5)
                        
                        Spacer()
                        
                        Button(action: { showUserProfile.toggle() }) {
                            Image(systemName: "person.crop.badge.magnifyingglass.fill")
                                .font(.system(size: 25))
                                .foregroundColor(Color("TX2"))
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 4)
                }
                
                contentView
                    .padding(.top, selectedTab == .home ? 44 : 20)
                
                Spacer()
                
                if !hideTabBar {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                        
                        HStack {
                            Spacer()
                            TabButton(icon: "globe.europe.africa.fill", title: "القصص", isSelected: selectedTab == .stories) {
                                selectedTab = .stories
                            }
                            Spacer()
                            TabButton(icon: "shareplay", title: "الرئيسية", isSelected: selectedTab == .home) {
                                selectedTab = .home
                            }
                            Spacer()
                            TabButton(icon: "message.fill", title: "الدردشات", isSelected: selectedTab == .chats) {
                                selectedTab = .chats
                            }
                            Spacer()
                        }
                        .frame(height: 60)
                        .background(Color("BackgroundColor"))
                    }
                }

                // هنا فقط ضع الموديفاير على الـ VStack الخارجي:
                }
                .background(Color("BackgroundColor").ignoresSafeArea())

                
                
                    .sheet(isPresented: $showUserProfile) {
                        Text("ملف المستخدم")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .sheet(isPresented: $showEditProfile) {
                        ProfileEditorView(userProfileVM: userProfileVM)
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        userProfileVM.loadUserProfile()
                    }
            }
        }
        
        var tabTitle: String {
            switch selectedTab {
            case .stories: return "القصص"
            case .home: return "الرئيسية"
            case .chats: return "الدردشات"
            }
        }
        
        @ViewBuilder
        var contentView: some View {
            switch selectedTab {
            case .stories:
                Text("محتوى القصص")
                    .foregroundColor(Color("TX2"))
                
            case .home:
                VStack(alignment: .trailing) {
                    ZStack(alignment: .bottomTrailing) {
                        if let header = userProfileVM.headerImage {
                            Image(uiImage: header)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                        }
                        
                        if let avatar = userProfileVM.profileImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color("BackgroundColor"), lineWidth: 4))
                                .offset(x: -16, y: 45)
                        }
                    }
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(userProfileVM.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("TX2"))
                            .padding(.trailing)
                        
                        // عرض البايو فقط لو مو فاضي
                        if !userProfileVM.description.isEmpty {
                            Text("\"\(userProfileVM.description)\"")
                                .font(.subheadline)
                                .foregroundColor(Color("TX2"))
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 12) {
                            if let birthDate = userProfileVM.birthDate {
                                Label {
                                    Text("وُلِد \(formattedDate(birthDate))")
                                } icon: {
                                    Image(systemName: "figure.wave")
                                }
                            }
                            
                            if !userProfileVM.location.isEmpty {
                                Label {
                                    Text(userProfileVM.location)
                                } icon: {
                                    Image(systemName: "mappin.and.ellipse")
                                }
                            }
                            
                            Label {
                                Text("انضم في أغسطس ٢٠١٩")
                            } icon: {
                                Image(systemName: "calendar")
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                    }
                    .padding(.top, 50)
                    
                    subTabContent
                }
                
            case .chats:
                ChatsView(hideTabBar: $hideTabBar)

                
            }
        }
        
        func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ar_SA")
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
        
        @ViewBuilder
        var subTabContent: some View {
            switch selectedSubTab {
            case .posts:
                VStack {
                    Spacer()
                    Text("لا توجد قصص")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.headline)
                    Spacer()
                }
            case .stories:
                VStack {
                    Spacer()
                    Text("لا توجد منشورات")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.headline)
                    Spacer()
                }
            }
        }
    }
    
    struct TabButton: View {
        let icon: String
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color.green : Color("TX2"))
                    Text(title)
                        .font(.caption)
                        .foregroundColor(isSelected ? Color.green : Color("TX2"))
                }
            }
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(userProfileVM: UserProfileViewModel())
                .environment(\.colorScheme, .light)
            
            HomeView(userProfileVM: UserProfileViewModel())
                .environment(\.colorScheme, .dark)
        }
    }
    

