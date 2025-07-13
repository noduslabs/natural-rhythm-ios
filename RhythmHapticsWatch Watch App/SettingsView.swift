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
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hurst: \(settings.hurstParameter, specifier: "%.1f")")
                        .font(.caption)
                    HStack {
                        Button("-") {
                            if settings.hurstParameter > 0.5 {
                                settings.hurstParameter = max(0.5, settings.hurstParameter - 0.1)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Button("+") {
                            if settings.hurstParameter < 2.0 {
                                settings.hurstParameter = min(2.0, settings.hurstParameter + 0.1)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Length: \(settings.signalLength)")
                        .font(.caption)
                    HStack {
                        Button("-") {
                            if settings.signalLength > 64 {
                                settings.signalLength = max(64, settings.signalLength - 64)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Button("+") {
                            if settings.signalLength < 512 {
                                settings.signalLength = min(512, settings.signalLength + 64)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base: \(settings.baseInterval, specifier: "%.2f")s")
                        .font(.caption)
                    HStack {
                        Button("-") {
                            if settings.baseInterval > 0.05 {
                                settings.baseInterval = max(0.05, settings.baseInterval - 0.05)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Button("+") {
                            if settings.baseInterval < 0.5 {
                                settings.baseInterval = min(0.5, settings.baseInterval + 0.05)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .frame(width: 30, height: 30)
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
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding(.top)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
