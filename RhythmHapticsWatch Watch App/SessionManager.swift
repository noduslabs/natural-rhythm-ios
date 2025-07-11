// SessionManager.swift
// Handles extended runtime session for always-on support

import Foundation
import WatchKit

class SessionManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        self.session = nil
        isSessionActive = false
        // Optionally handle reason or error here
    }
    
    static let shared = SessionManager()
    private var session: WKExtendedRuntimeSession?
    @Published var isSessionActive = false
    
    func startSession() {
        guard session == nil else { return }
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        isSessionActive = true
    }
    
    func stopSession() {
        session?.invalidate()
        session = nil
        isSessionActive = false
    }

    // MARK: - WKExtendedRuntimeSessionDelegate
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        isSessionActive = true
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Handle expiration warning if needed
    }
    
    func extendedRuntimeSessionDidInvalidate(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        self.session = nil
        isSessionActive = false
    }
}
