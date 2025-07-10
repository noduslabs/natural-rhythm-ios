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
    
    var body: some View {
        VStack {
            Text("Tap for Haptic Rhythm")
            Button("Start Rhythm") {
                playHapticRhythm()
            }
            .padding()
        }
    }

    func playHapticRhythm() {
        // Stop any existing timer
        timer?.invalidate()
        
        let rawIntervals = generateFractalSignal(length: 128, hurst: 1)
        let intervals = rawIntervals.map { 0.2 + $0 * 0.4 } // scale to [0.2, 0.6]
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    WKInterfaceDevice.current().play(.notification)
                    currentIndex += 1
                }
            } else {
                // All haptics completed
                timer?.invalidate()
                timer = nil
            }
        }
    }
}
