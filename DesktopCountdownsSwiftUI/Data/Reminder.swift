//
//  Reminder.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 6/27/20.
//
import Foundation

struct Reminder: Equatable, Identifiable, Hashable {
  var id: String = UUID().uuidString
  var title: String
  var dueDate: Date?
  var dueDateHasTime = false
  var countDownDays = 0
  var notes: String?
  var isComplete = false
  var priority: Int = 0 // RFC 5545 allows priority to be specified with an integer in the range of 0-9, with 0 representing an undefined priority, 1 the highest priority, and 9 the lowest priority.
}

#if DEBUG
// swiftlint:disable no_magic_numbers
extension Reminder {
  private static var secondsInADay = 86_400.0
  
  static var sampleData = [
    Reminder(
      title: "Submit reimbursement report",
      dueDate: Date().addingTimeInterval(1 * secondsInADay),
      countDownDays: 1,
      notes: "Don't forget about taxi receipts",
      priority: 9
    ),
    Reminder(
      title: "Code review",
      dueDate: Date().addingTimeInterval(2 * secondsInADay),
      countDownDays: 2,
      notes: "Check tech specs in shared folder",
      isComplete: true,
      priority: 1
    ),
    Reminder(
      title: "Pick up new contacts",
      dueDate: Date().addingTimeInterval(4 * secondsInADay),
      dueDateHasTime: true,
      countDownDays: 4,
      notes: "Optometrist closes at 6:00PM",
      priority: 6
    ),
    Reminder(
      title: "Add notes to retrospective",
      dueDate: Date().addingTimeInterval(8 * secondsInADay),
      countDownDays: 8,
      notes: "Collaborate with project manager",
      isComplete: true,
      priority: 1
    ),
    Reminder(
      title: "Interview new candidate",
      dueDate: Date().addingTimeInterval(60_000.0),
      dueDateHasTime: true,
      countDownDays: Date().addingTimeInterval(60_000.0).daysBetween(Date()),
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
      countDownDays: 12,
      notes: "Discuss trends with management"
    ),
    Reminder(
      title: "Confirm group reservation",
      dueDate: Date().addingTimeInterval(3 * secondsInADay),
      dueDateHasTime: true,
      countDownDays: 3,
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
      countDownDays: 50,
      notes: "Think different",
      priority: 7
    )
  ]
}
// swiftlint:enable no_magic_numbers
#endif
