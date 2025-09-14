//
//  StoryModel.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import Foundation

struct StoryModel: Identifiable {
    let id = UUID()
    let userId: String
    let imageURL: String
    let timestamp: Date
}
