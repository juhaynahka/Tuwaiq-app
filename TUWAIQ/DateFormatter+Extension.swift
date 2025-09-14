//
//  DateFormatter+Extension.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import Foundation

extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
