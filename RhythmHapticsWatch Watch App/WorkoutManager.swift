// WorkoutManager.swift
// Handles HealthKit workout session for always-on display

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let types: Set = [HKObjectType.workoutType()]
        healthStore.requestAuthorization(toShare: types, read: types) { success, _ in
            completion(success)
        }
    }
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            session?.delegate = self
            builder?.beginCollection(withStart: Date(), completion: { _,_ in })
            session?.startActivity(with: Date())
        } catch {
            print("Failed to start workout session: \(error)")
        }
    }
    
    func stopWorkout() {
        session?.end()
    }
    
    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
}
