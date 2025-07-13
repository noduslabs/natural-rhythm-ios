//
//  SettingsModel.swift
//  RhythmHaptics
//
//  Created by Dmitry Paranyushkin on 07/13/2025.
//

import Foundation

class SettingsModel: ObservableObject {
    static let shared = SettingsModel()
    
    @Published var hurstParameter: Double {
        didSet {
            UserDefaults.standard.set(hurstParameter, forKey: "hurstParameter")
        }
    }
    
    @Published var signalLength: Int {
        didSet {
            UserDefaults.standard.set(signalLength, forKey: "signalLength")
        }
    }
    
    @Published var intensityMultiplier: Double {
        didSet {
            UserDefaults.standard.set(intensityMultiplier, forKey: "intensityMultiplier")
        }
    }
    
    @Published var baseInterval: Double {
        didSet {
            UserDefaults.standard.set(baseInterval, forKey: "baseInterval")
        }
    }
    
    @Published var hapticStyle: Int {
        didSet {
            UserDefaults.standard.set(hapticStyle, forKey: "hapticStyle")
        }
    }
    
    private init() {
        self.hurstParameter = UserDefaults.standard.object(forKey: "hurstParameter") as? Double ?? 1.1
        self.signalLength = UserDefaults.standard.object(forKey: "signalLength") as? Int ?? 256
        self.intensityMultiplier = UserDefaults.standard.object(forKey: "intensityMultiplier") as? Double ?? 2.0
        self.baseInterval = UserDefaults.standard.object(forKey: "baseInterval") as? Double ?? 0.1
        self.hapticStyle = UserDefaults.standard.object(forKey: "hapticStyle") as? Int ?? 0
    }
}