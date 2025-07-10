//
//  ContentView.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var timer: Timer?
    @State private var isPlaying = false
    
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
        // Stop any existing timer
        timer?.invalidate()
        
        isPlaying = true
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        let rawIntervals = generateFractalSignal(length: 128, hurst: 1)
        let intervals = rawIntervals.map { 0.2 + $0 * 0.4 } // scale to [0.2, 0.6]
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    generator.impactOccurred()
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
    }
}
