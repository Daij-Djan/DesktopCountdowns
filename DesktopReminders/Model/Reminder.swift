//
//  Reminder.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Foundation
import EventKit

struct Reminder: Equatable, Identifiable {
  var id: String = UUID().uuidString
  var title: String
  var dueDate: Date?
    var dueDateHasTime: Bool = false
  var notes: String? = nil
  var isComplete: Bool = false
  var priority: Int = 0 //RFC 5545 allows priority to be specified with an integer in the range of 0-9, with 0 representing an undefined priority, 1 the highest priority, and 9 the lowest priority.
}

extension Reminder {
  init(with ekReminder: EKReminder) {
    id = ekReminder.calendarItemIdentifier
    title = ekReminder.title
    dueDate = ekReminder.dueDateComponents?.date
    if dueDate == nil {
      dueDate = ekReminder.alarms?.first?.absoluteDate
    }
    if let dueDate = dueDate {
      let comps = Calendar.current.dateComponents([.hour, .minute], from: dueDate)
      if let hour = comps.hour, let minute = comps.minute {
        dueDateHasTime = hour != 0 || minute != 0;
      }
    }
    isComplete = ekReminder.isCompleted
    priority = ekReminder.priority
  }
}

#if DEBUG
extension Reminder {
  fileprivate static var day = 86400.0
  
  static var sampleData = [
    Reminder(
      title: "Submit reimbursement report",
      dueDate: Date().addingTimeInterval(1 * day),
      notes: "Don't forget about taxi receipts",
      priority: 9),
    Reminder(
      title: "Code review",
      dueDate: Date().addingTimeInterval(2 * day),
      notes: "Check tech specs in shared folder",
      isComplete: true,
      priority: 1),
    Reminder(
      title: "Pick up new contacts",
      dueDate: Date().addingTimeInterval(4 * day),
      dueDateHasTime: true,
      notes: "Optometrist closes at 6:00PM",
      priority: 6),
    Reminder(
      title: "Add notes to retrospective",
      dueDate: Date().addingTimeInterval(8 * day),
      notes: "Collaborate with project manager",
      isComplete: true,
      priority: 1),
    Reminder(
      title: "Interview new candidate",
      dueDate: Date().addingTimeInterval(60000.0),
      dueDateHasTime: true,
      notes: "Review portfolio",
      priority:4),
    Reminder(
      title: "Mock up onboarding experience",
      notes: "Think different",
      priority:10),
    Reminder(
      title: "Review usage analytics",
      dueDate: Date().addingTimeInterval(12 * day),
      notes: "Discuss trends with management"),
    Reminder(
      title: "Confirm group reservation",
      dueDate: Date().addingTimeInterval(3 * day),
      dueDateHasTime: true,
      notes: "Ask about space heaters"),
    Reminder(
      title: "Add beta testers to TestFlight",
      notes: "v0.9 out on Friday",
      priority: 3),
    Reminder(
      title: "Mock up onboarding experience",
      dueDate: Date().addingTimeInterval(50 * day),
      dueDateHasTime: true,
      notes: "Think different",
      priority:7),
  ]
}
#endif
