//
//  SettingsView.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/13/2025.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var settings = SettingsModel.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Fractal Parameters")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Hurst Parameter")
                            Spacer()
                            Text("\(settings.hurstParameter, specifier: "%.2f")")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.hurstParameter, in: 0.5...2.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Signal Length")
                            Spacer()
                            Text("\(settings.signalLength)")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(settings.signalLength) },
                            set: { settings.signalLength = Int($0) }
                        ), in: 64...512, step: 64)
                    }
                }
                
                Section(header: Text("Timing")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Base Interval")
                            Spacer()
                            Text("\(settings.baseInterval, specifier: "%.2f")s")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.baseInterval, in: 0.05...2.0, step: 0.05)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Intensity Multiplier")
                            Spacer()
                            Text("\(settings.intensityMultiplier, specifier: "%.1f")")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.intensityMultiplier, in: 0.5...5.0, step: 0.5)
                    }
                }
                
                Section(header: Text("Haptic Feedback")) {
                    Picker("Haptic Style", selection: $settings.hapticStyle) {
                        Text("Light").tag(0)
                        Text("Medium").tag(1)
                        Text("Heavy").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}