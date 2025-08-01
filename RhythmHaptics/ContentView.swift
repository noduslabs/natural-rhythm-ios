//
//  ContentView.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import UIKit
import AVFoundation

struct ContentView: View {
    init() {
        // Set up audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
    @State private var timer: Timer?
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            Text("Tap to Feel the Fractal")
            Button(isPlaying ? "Stop" : "Start") {
                if isPlaying {
                    stopHapticRhythm()
                } else {
                    playHapticRhythm()
                }
            }
            .padding()
        }
    }

    func playHapticRhythm() {
        // Prepare audio player
        if let soundURL = Bundle.main.url(forResource: "beat", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound: \(error)")
            }
        }
        // Stop any existing timer
        timer?.invalidate()
        
        isPlaying = true
        UIApplication.shared.isIdleTimerDisabled = true // Keep screen on
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        let rawIntervals = generateFractalSignal(length: 256, hurst: 1.1)
        let intervals: [Double] = rawIntervals.map { 0.1 + $0 * 2 }
        var pairSums: [Double] = []
        pairSums.reserveCapacity(intervals.count / 2 + intervals.count % 2)
        for i in stride(from: 0, to: intervals.count, by: 2) {
            let sum = intervals[i] + (i + 1 < intervals.count ? intervals[i + 1] : 0)
            pairSums.append(sum)
        }
        print("Pair sums: \(pairSums.map { String(format: "%.4f", $0) }.joined(separator: ", "))")

        
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    generator.impactOccurred()
                    audioPlayer?.play()
                    currentIndex += 1
                }
            } else {
                // All haptics completed
                stopHapticRhythm()
            }
        }
    }
    
    func stopHapticRhythm() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false // Allow screen to sleep
    }
}
