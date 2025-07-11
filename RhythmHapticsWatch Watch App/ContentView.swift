//
//  ContentView.swift
//  RhythmHapticsWatch Watch App
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import WatchKit
import HealthKit


struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()
    @State private var timer: Timer?
    @State private var isPlaying = false
    @State private var isStarting = false
    
    var body: some View {
        VStack {
        }
        .privacySensitive(false) // Allows always-on display support
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
        .onAppear {
            workoutManager.requestAuthorization { _ in }
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
        SessionManager.shared.startSession() // Start extended runtime session
        workoutManager.startWorkout() // Start workout session for always-on
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
        
        let rawIntervals = generateFractalSignal(length: 256, hurst: 1.1)
        let intervals = rawIntervals.map { 0.1 + $0 * 2 } // scale to [0.2, 0.6] 0.2 $0 * 0.4 will be faster
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    WKInterfaceDevice.current().play(.start) // success is double but nice, failure is longer vibration
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
        SessionManager.shared.stopSession() // Stop extended runtime session
        workoutManager.stopWorkout() // Stop workout session
        isStarting = false
    }
}
