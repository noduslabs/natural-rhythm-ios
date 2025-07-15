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
    @ObservedObject private var settings = SettingsModel.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Tap to Feel the Fractal")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Button(buttonText) {
                    if isPlaying {
                        stopHapticRhythm()
                    } else {
                        startHapticRhythm()
                    }
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding()
                
                NavigationLink("Settings") {
                    SettingsView()
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .privacySensitive(false)
            .navigationTitle("RhythmHaptics")
            .navigationBarTitleDisplayMode(.inline)
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
        
        let rawIntervals = generateFractalSignal(length: settings.signalLength, hurst: settings.hurstParameter)
        let intervals = rawIntervals.map { settings.baseInterval + $0 * settings.intensityMultiplier }
        
        var currentIndex = 0
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if currentIndex < intervals.count {
                let expectedTime = intervals.prefix(currentIndex).reduce(0, +)
                
                if elapsed >= expectedTime {
                    let currentInterval = intervals[currentIndex]
                    
                    // Check if extended feedback is enabled and intensityMultiplier >= 1
                    if settings.extendedHapticFeedback && settings.intensityMultiplier >= 1.0 {
                        playExtendedHapticPattern(for: currentInterval, startTime: expectedTime)
                    } else {
                        playSelectedSignal()
                    }
                    
                    currentIndex += 1
                }
            } else {
                // All haptics completed
                stopHapticRhythm()
            }
        }
    }
    
    func playExtendedHapticPattern(for interval: Double, startTime: Double) {
        // Generate more impulses with gradual acceleration-deceleration
        let totalHaptics = max(7, Int(interval * 12)) // More haptics
        let maxHaptics = 15 // Increased cap
        let actualHaptics = min(totalHaptics, maxHaptics)
        
        var delays: [Double] = []
        delays.append(0.0) // First haptic at start
        
        var currentTime = 0.0
        let totalAvailableTime = interval * 0.95 // Use 95% of interval
        
        // Pre-calculate all gap sizes to ensure we fill the available time
        var gapSizes: [Double] = []
        for i in 1..<actualHaptics {
            let progress = Double(i - 1) / Double(actualHaptics - 2) // 0 to 1 for intervals between haptics
            
            // Create gradual acceleration-deceleration curve for intervals
            let gapSize: Double
            if progress <= 0.5 {
                // First half: accelerating (decreasing gaps)
                let accelProgress = progress * 2 // 0 to 1
                let maxGap = 1.0 // Start with large relative gaps
                let minGap = 0.2 // End with small relative gaps
                gapSize = maxGap - (maxGap - minGap) * pow(accelProgress, 1.5)
            } else {
                // Second half: decelerating (increasing gaps)
                let decelProgress = (progress - 0.5) * 2 // 0 to 1
                let minGap = 0.2 // Start with small relative gaps
                let maxGap = 1.0 // End with large relative gaps
                gapSize = minGap + (maxGap - minGap) * pow(decelProgress, 1.5)
            }
            gapSizes.append(gapSize)
        }
        
        // Scale gaps to fit available time
        let totalRelativeGaps = gapSizes.reduce(0, +)
        let scaleFactor = totalAvailableTime / totalRelativeGaps
        
        // Generate actual delays
        for gapSize in gapSizes {
            currentTime += gapSize * scaleFactor
            delays.append(currentTime)
        }
        
        // Schedule all haptics
        for delay in delays {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.isPlaying {
                    self.playSelectedSignal()
                }
            }
        }
    }
    
    func playSelectedSignal() {
        switch settings.signalType {
        case 0: // Start
            WKInterfaceDevice.current().play(.start)
        case 1: // Success
            WKInterfaceDevice.current().play(.success)
        case 2: // Failure
            WKInterfaceDevice.current().play(.failure)
        default:
            WKInterfaceDevice.current().play(.start)
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
