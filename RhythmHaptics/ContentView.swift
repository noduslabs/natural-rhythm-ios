//
//  ContentView.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/07/2025.
//

import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox

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
    @State private var showingSettings = false
    @State private var customSoundID: SystemSoundID = 0
    @ObservedObject private var settings = SettingsModel.shared
    
    // Visual feedback state
    @State private var squareSize: CGFloat = 0
    @State private var isGrowing = true
    @State private var intervalCount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Visual feedback square (background layer)
                if settings.extendedHapticFeedback && settings.intensityMultiplier >= 1.0 && isPlaying {
                    Rectangle()
                        .fill(Color.primary.opacity(1))
                        .frame(width: squareSize, height: squareSize)
                        .animation(.linear(duration: 0.1), value: squareSize)
                }
                
                // UI content (foreground layer)
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
                .navigationTitle("RhythmHaptics")
                .navigationBarItems(trailing: Button("Settings") {
                    showingSettings = true
                })
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }

    func playHapticRhythm() {
        // Register custom sound
        if let soundURL = Bundle.main.url(forResource: "beat", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &customSoundID)
        }
        
        // Stop any existing timer
        timer?.invalidate()
        
        isPlaying = true
        UIApplication.shared.isIdleTimerDisabled = true // Keep screen on
        
        // Reset visual feedback state
        squareSize = 0
        intervalCount = 0
        isGrowing = true
        
        let hapticStyles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy]
        let generator = UIImpactFeedbackGenerator(style: hapticStyles[settings.hapticStyle])
        let rawIntervals = generateFractalSignal(length: settings.signalLength, hurst: settings.hurstParameter)
        let intervals: [Double] = rawIntervals.map { settings.baseInterval + $0 * settings.intensityMultiplier }
        var pairSums: [Double] = []
        pairSums.reserveCapacity(intervals.count / 2 + intervals.count % 2)
        for i in stride(from: 0, to: intervals.count, by: 2) {
            let sum = intervals[i] + (i + 1 < intervals.count ? intervals[i + 1] : 0)
            pairSums.append(sum)
        }
        print("Intervals: \(intervals.map { String(format: "%.4f", $0) }.joined(separator: ", "))")

        
        
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
                        generator.impactOccurred()
                        playSelectedSound()
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
        let totalHaptics = max(8, Int(interval * 12)) // More haptics
        let maxHaptics = 8 // Increased cap
        let actualHaptics = min(totalHaptics, maxHaptics)
        
        let hapticStyles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy]
        let generator = UIImpactFeedbackGenerator(style: hapticStyles[settings.hapticStyle])
        let generatorExtended = UIImpactFeedbackGenerator(style: .light)
        let generatorExtendedCadence = UIImpactFeedbackGenerator(style: .heavy)
        
        var delays: [Double] = []
        delays.append(0.0) // First haptic at start
        
        var currentTime = 0.0
        let totalAvailableTime = interval * 0.8 // Use 80% of interval
        
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
        
        // Update interval count and growing state
        intervalCount += 1
        isGrowing = intervalCount % 2 == 1 // Odd intervals grow, even intervals shrink
        
        // Calculate max screen size for iPhone
        let screenSize: CGFloat = UIScreen.main.bounds.width
        
        print("delays: \(delays.map { String(format: "%.4f", $0) }.joined(separator: ", "))")
        
        // Schedule all haptics and sounds with visual feedback
        for (index, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.isPlaying {
                    // Update visual feedback
                    let progress = Double(index) / Double(delays.count - 1)
                    if self.isGrowing {
                        self.squareSize = CGFloat(progress) * screenSize
                    } else {
                        self.squareSize = CGFloat(1.0 - progress) * screenSize
                    }
                    
                    // Play haptic feedback
                    if settings.extendedHapticFeedback && settings.intensityMultiplier >= 1.0 {
                        if index == 0 {
                            generatorExtendedCadence.impactOccurred()
                            self.playSelectedSound(soundType: 0)
                        }
                        else {
                            generatorExtended.impactOccurred()
                            self.playSelectedSound()
                        }
                    } else {
                        generator.impactOccurred()
                        self.playSelectedSound()
                    }
                }
            }
        }
    }
    
    func playSelectedSound(soundType: Int? = nil) {
        let type = soundType ?? settings.soundType
        switch type {
        case 0: // Beat (custom sound)
            AudioServicesPlaySystemSound(customSoundID)
        case 1: // Lock
            AudioServicesPlaySystemSound(1100)
        case 2: // Tink
            AudioServicesPlaySystemSound(1057)
        case 3: // Click
            AudioServicesPlaySystemSound(1104)
        default:
            AudioServicesPlaySystemSound(customSoundID)
        }
    }
    
    func stopHapticRhythm() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false // Allow screen to sleep
        
        // Clean up custom sound
        if customSoundID != 0 {
            AudioServicesDisposeSystemSoundID(customSoundID)
            customSoundID = 0
        }
        
        // Reset visual feedback state
        squareSize = 0
        intervalCount = 0
        isGrowing = true
    }
}
