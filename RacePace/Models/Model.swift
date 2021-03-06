//
//  Model.swift
//  RacePace
//
//  Created by Austin Louden on 4/24/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

import Foundation

struct Event: Codable {
  let race: Race
  let time: FinishTime
}

struct RaceResult: Hashable {
  let identifier = UUID()
  let pace: Pace
  let finishTime: FinishTime

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: RaceResult, rhs: RaceResult) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

struct FinishTime: Equatable, Codable {
  let hours: Int
  let minutes: Int
  let seconds: Int

  func finishTimeString() -> String {
    return
      "\(String(format: "%02d", self.hours)):\(String(format: "%02d", self.minutes)):\(String(format: "%02d", self.seconds))"
  }

  func timeInMinutes() -> Double {
    return Double(hours) * 60.0 + Double(minutes) + Double(seconds) / 60.0
  }

  func timeInSeconds() -> Int {
    return hours * 3600 + minutes * 60 + seconds
  }

  static func finishTime(with seconds: Int) -> FinishTime {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let seconds = seconds % 60

    return FinishTime(hours: hours, minutes: minutes, seconds: seconds)
  }
}

struct Pace {
  let minutes: Int
  let seconds: Int
  let name: String?

  func paceString() -> String {
    return "\(self.minutes):\(String(format: "%02d", self.seconds))"
  }
}

struct CustomRace: Codable, Equatable {
  let rawDistance: Double
  let metric: Bool

  func distance() -> Double {
    return self.metric ? self.rawDistance * 0.621371 : self.rawDistance
  }

  func distanceString() -> String {
    return "\(String(rawDistance)) " + (metric ? "km" : "mi")
  }

  func unitString() -> String {
    return metric ? "kilometers" : "miles"
  }
}

public enum Race: Int, CaseIterable, Codable {
  case fiveK
  case tenK
  case halfMarathon
  case marathon
  case custom

  var distance: Double {
    switch self {
    case .fiveK:
      return 3.10686
    case .tenK:
      return 6.21371
    case .halfMarathon:
      return 13.1094
    case .marathon:
      return 26.2188
    case .custom:
      guard let customRace = store.state.raceState.customRace else { return 0.0 }
      return customRace.distance()
    }
  }

  var shortString: String {
    switch self {
    case .fiveK:
      return "5K"
    case .tenK:
      return "10K"
    case .halfMarathon:
      return "13.1"
    case .marathon:
      return "26.2"
    case .custom:
      return store.state.raceState.customRace?.distanceString() ?? ""
    }
  }

  var longString: String {
    switch self {
    case .fiveK:
      return "5K"
    case .tenK:
      return "10K"
    case .halfMarathon:
      return "Half Marathon"
    case .marathon:
      return "Marathon"
    case .custom:
      return store.state.raceState.customRace?.distanceString() ?? ""
    }
  }
}

func finishTime(with pace: Pace, distance: Double) -> FinishTime {
  let paceInSeconds = 60 * pace.minutes + pace.seconds
  let finishTimeInSeconds = Int(round(distance * Double(paceInSeconds)))
  return FinishTime.finishTime(with: finishTimeInSeconds)
}
