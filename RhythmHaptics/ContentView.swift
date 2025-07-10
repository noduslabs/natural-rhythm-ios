//
//  ContentView.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
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
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        let intervals = generateFractalSignal(length: 128, hurst: 1)
        var currentTime: Double = 0
        for interval in intervals {
            let delay = currentTime
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                generator.impactOccurred()
            }
            // Scale interval to a practical range, e.g. 0.2–0.8 seconds
            currentTime += 0.2 + interval * 0.6
        }
    }
}
