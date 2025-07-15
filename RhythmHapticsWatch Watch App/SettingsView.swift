//
//  SettingsView.swift
//  RhythmHapticsWatch Watch App
//
//  Created by Dmitry Paranyushkin on 07/13/2025.
//

import SwiftUI
import WatchKit

struct SettingsView: View {
    @ObservedObject var settings = SettingsModel.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hurst: \(settings.hurstParameter, specifier: "%.1f")")
                    .font(.caption)
                Slider(value: $settings.hurstParameter, in: 0.2...2.0, step: 0.1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Length: \(settings.signalLength)")
                    .font(.caption)
                Slider(value: Binding(
                    get: { Double(settings.signalLength) },
                    set: { settings.signalLength = Int($0) }
                ), in: 64...512, step: 64)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Base: \(settings.baseInterval, specifier: "%.2f")s")
                    .font(.caption)
                Slider(value: $settings.baseInterval, in: 0.05...2.0, step: 0.05)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Multiplier: \(settings.intensityMultiplier, specifier: "%.1f")")
                    .font(.caption)
                Slider(value: $settings.intensityMultiplier, in: 0.25...10.0, step: 0.25)
                    .onChange(of: settings.intensityMultiplier) { newValue in
                        if newValue < 1.0 {
                            settings.extendedHapticFeedback = false
                        }
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Style: \(["Light", "Medium", "Heavy"][settings.hapticStyle])")
                    .font(.caption)
                HStack {
                    Button("Light") {
                        settings.hapticStyle = 0
                    }
                    .buttonStyle(.bordered)
                    .background(settings.hapticStyle == 0 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                    
                    Button("Med") {
                        settings.hapticStyle = 1
                    }
                    .buttonStyle(.bordered)
                    .background(settings.hapticStyle == 1 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                    
                    Button("Heavy") {
                        settings.hapticStyle = 2
                    }
                    .buttonStyle(.bordered)
                    .background(settings.hapticStyle == 2 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Signal: \(["Start", "Success", "Failure"][settings.signalType])")
                    .font(.caption)
                HStack {
                    Button("Start") {
                        settings.signalType = 0
                    }
                    .buttonStyle(.bordered)
                    .background(settings.signalType == 0 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                    
                    Button("Success") {
                        settings.signalType = 1
                    }
                    .buttonStyle(.bordered)
                    .background(settings.signalType == 1 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                    
                    Button("Failure") {
                        settings.signalType = 2
                    }
                    .buttonStyle(.bordered)
                    .background(settings.signalType == 2 ? Color.accentColor : Color.clear)
                    .font(.caption2)
                }
            }
            
            HStack {
                Text("Extended Feedback")
                    .font(.caption)
                Spacer()
                Toggle("", isOn: $settings.extendedHapticFeedback)
                    .disabled(settings.intensityMultiplier < 1.0)
            }
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
