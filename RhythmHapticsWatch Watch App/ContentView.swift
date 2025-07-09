//
//  ContentView.swift
//  RhythmHapticsWatch Watch App
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import WatchKit

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
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
}
