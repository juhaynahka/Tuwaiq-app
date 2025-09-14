//
//  AudioPlayer.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import AVFoundation

class AudioPlayer: NSObject, ObservableObject {
    private var player: AVAudioPlayer?

    func playAudio(at url: URL) {
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
