//
//  AudioRecorder.swift
//  طويق
//
//  Created by Tuwaiq.IT on 13/02/1447 AH.
//

import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    @Published var isRecording = false

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audio.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.record()
        isRecording = true
    }

    func stopRecording() {
        recorder?.stop()
        isRecording = false
    }
}
