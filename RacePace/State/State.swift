//
//  State.swift
//  Process
//
//  Created by Austin Louden on 4/22/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

import Foundation
import UIKit

fileprivate(set) public var appState = State()

public struct State {
    // paces
    var pace = 8
    var race = Race.marathon
    var expanded = false
    var selectingDistance = false

    // projections
    var lastRace: Event?
    var goalRace: Event?
}

enum Action: Equatable {
    // paces
    case selectRace(race: Race)
    case incrementPace
    case decrementPace
    case toggleExpansion
    case toggleDistanceSelection
    case saveCustomRace(race: CustomRace)
    
    // projections
    case presentProjectionsNUX
    case setGoalRace(race: Race, time: FinishTime)
    case setLastRace(race: Race, time: FinishTime)
    case getRaces
}

func reduce(action: Action, state: State?) {
    var state = state ?? State()
    
    switch action {
    case .selectRace(let race):
        UIImpactFeedbackGenerator().impactOccurred()
        state.race = race
    case .incrementPace:
        UIImpactFeedbackGenerator().impactOccurred()
        state.pace = updatePace(pace: state.pace, increment: true)
    case .decrementPace:
        UIImpactFeedbackGenerator().impactOccurred()
        state.pace = updatePace(pace: state.pace, increment: false)
    case .toggleExpansion:
        UIImpactFeedbackGenerator().impactOccurred()
        state.expanded = !state.expanded
    case .toggleDistanceSelection:
        UIImpactFeedbackGenerator().impactOccurred()
        state.selectingDistance = !state.selectingDistance
        state.expanded = false
    case .saveCustomRace(let race):
        saveCustomRace(race)
        
        
    // projections
    case .presentProjectionsNUX:
        break
    case .setGoalRace(let race, let time):
        state.goalRace = Event(race: race, time: time)
        storeRace(race, time, true)
    case .setLastRace(let race, let time):
        state.lastRace = Event(race: race, time: time)
        storeRace(race, time, false)
    case .getRaces:
        if let races = retrieveRaces() {
            state.lastRace = races.0
            state.goalRace = races.1
        }
    }
    
    appState = state
    NotificationCenter.default.post(name: .stateDidChange, object: action)
}

private func updatePace(pace: Int, increment: Bool) -> Int {
    let newPace = increment ? pace + 1 : pace - 1
    
    if (newPace > -1 && newPace < 31) {
        return newPace
    }

    UINotificationFeedbackGenerator().notificationOccurred(.error)
    return pace
}

private func saveCustomRace(_ race: CustomRace) {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(race), forKey:kCustomRaceKey)
}

func getCustomRace() -> CustomRace? {
    guard let raceData = UserDefaults.standard.value(forKey:kCustomRaceKey) as? Data else { return nil }
    guard let race = try? PropertyListDecoder().decode(CustomRace.self, from: raceData) else { return nil }
    return race
}

private func storeRace(_ race: Race, _ time: FinishTime, _ isGoal: Bool) {
    let event = Event(race: race, time: time)
    let key = isGoal ? kGoalRaceKey : kLastRaceKey
    UserDefaults.standard.set(try? PropertyListEncoder().encode(event), forKey:key)
}

private func retrieveRaces() -> (Event, Event)? {
    guard let goalData = UserDefaults.standard.value(forKey:kGoalRaceKey) as? Data else { return nil }
    guard let lastData = UserDefaults.standard.value(forKey:kLastRaceKey) as? Data else { return nil }
    
    guard let goal = try? PropertyListDecoder().decode(Event.self, from: goalData) else { return nil }
    guard let last = try? PropertyListDecoder().decode(Event.self, from: lastData) else { return nil }

    return (last, goal)
}

extension Notification.Name {
    static let stateDidChange = Notification.Name("stateDidChange")
}
