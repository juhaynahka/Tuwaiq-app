//
//  TypingIndicatorView.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import SwiftUI

import SwiftUI

struct TypingIndicatorView: View {
    @State private var dots: String = ""
    private let typingText = "..."

    var body: some View {
        Text(dots)
            .font(.headline)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    dots = dots.count < typingText.count ? dots + "." : ""
                }
            }
    }
}

#Preview {
    TypingIndicatorView()
}
