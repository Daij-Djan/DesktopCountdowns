//
//  Reminder.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 6/27/20.
//

import EventKit
import Foundation

struct Reminder: Equatable, Identifiable {
  var id: String = UUID().uuidString
  var title: String
  var dueDate: Date?
    var dueDateHasTime = false
  var notes: String?
  var isComplete = false
  var priority: Int = 0 // RFC 5545 allows priority to be specified with an integer in the range of 0-9, with 0 representing an undefined priority, 1 the highest priority, and 9 the lowest priority.
}

extension Reminder {
  init(with ekReminder: EKReminder) {
    id = ekReminder.calendarItemIdentifier
    title = ekReminder.title
    dueDate = ekReminder.dueDateComponents?.date
    if dueDate == nil {
      dueDate = ekReminder.alarms?.first?.absoluteDate
    }
    if let dueDate {
      let comps = Calendar.current.dateComponents([.hour, .minute], from: dueDate)
      if let hour = comps.hour, let minute = comps.minute {
        dueDateHasTime = hour != 0 || minute != 0
      }
    }
    isComplete = ekReminder.isCompleted
    priority = ekReminder.priority
  }
}

#if DEBUG
// swiftlint:disable no_magic_numbers
extension Reminder {
  private static var secondsInADay = 86_400.0

  static var sampleData = [
    Reminder(
      title: "Submit reimbursement report",
      dueDate: Date().addingTimeInterval(1 * secondsInADay),
      notes: "Don't forget about taxi receipts",
      priority: 9
    ),
    Reminder(
      title: "Code review",
      dueDate: Date().addingTimeInterval(2 * secondsInADay),
      notes: "Check tech specs in shared folder",
      isComplete: true,
      priority: 1
    ),
    Reminder(
      title: "Pick up new contacts",
      dueDate: Date().addingTimeInterval(4 * secondsInADay),
      dueDateHasTime: true,
      notes: "Optometrist closes at 6:00PM",
      priority: 6
    ),
    Reminder(
      title: "Add notes to retrospective",
      dueDate: Date().addingTimeInterval(8 * secondsInADay),
      notes: "Collaborate with project manager",
      isComplete: true,
      priority: 1
    ),
    Reminder(
      title: "Interview new candidate",
      dueDate: Date().addingTimeInterval(60_000.0),
      dueDateHasTime: true,
      notes: "Review portfolio",
      priority: 4
    ),
    Reminder(
      title: "Mock up onboarding experience",
      notes: "Think different",
      priority: 10
    ),
    Reminder(
      title: "Review usage analytics",
      dueDate: Date().addingTimeInterval(12 * secondsInADay),
      notes: "Discuss trends with management"
    ),
    Reminder(
      title: "Confirm group reservation",
      dueDate: Date().addingTimeInterval(3 * secondsInADay),
      dueDateHasTime: true,
      notes: "Ask about space heaters"
    ),
    Reminder(
      title: "Add beta testers to TestFlight",
      notes: "v0.9 out on Friday",
      priority: 3
    ),
    Reminder(
      title: "Mock up onboarding experience",
      dueDate: Date().addingTimeInterval(50 * secondsInADay),
      dueDateHasTime: true,
      notes: "Think different",
      priority: 7
    )
  ]
}
// swiftlint:enable no_magic_numbers
#endif
