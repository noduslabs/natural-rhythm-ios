//
//  ContentView.swift
//  RhythmHapticsWatch Watch App
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import WatchKit


struct ContentView: View {
    @State private var timer: Timer?
    @State private var isPlaying = false
    @State private var isStarting = false
    
    var body: some View {
        VStack {
            Text("Tap to Feel the Fractal")
            Button(buttonText) {
                if isPlaying {
                    stopHapticRhythm()
                } else {
                    startHapticRhythm()
                }
            }
            .padding()
        }
    }
    
    private var buttonText: String {
        if isStarting {
            return "Starting"
        } else if isPlaying {
            return "Stop"
        } else {
            return "Start"
        }
    }

    func startHapticRhythm() {
        isStarting = true
        
        // Use a brief delay to show "Starting" before actually starting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playHapticRhythm()
        }
    }

    func playHapticRhythm() {
        // Stop any existing timer
        timer?.invalidate()
        
        isStarting = false
        isPlaying = true
        
        let rawIntervals = generateFractalSignal(length: 128, hurst: 1)
        let intervals = rawIntervals.map { 0.2 + $0 * 0.4 } // scale to [0.2, 0.6]
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    WKInterfaceDevice.current().play(.failure)
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
        isStarting = false
    }
}
