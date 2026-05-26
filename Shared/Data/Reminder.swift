//
//  Reminder.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 6/27/20.
//
import Foundation

struct Reminder: Equatable, Identifiable, Hashable {
  enum ReminderType: String, Codable {
    case regular = "Regular"
    case birthday = "Birthday"
  }

  var id: String = UUID().uuidString
  var title: String
  var dueDate: Date?
  var dueDateHasTime = false
  var countDownDays = 0
  var countDownHours = 0
  var notes: String?
  var isComplete = false
  var isFlagged = false
  var priority: Int = 0 // RFC 5545 allows priority to be specified with an integer in the range of 0-9, with 0 representing an undefined priority, 1 the highest priority, and 9 the lowest priority.
  var tags: [String] = []
  var attachmentImageURLs: [URL] = []
  var reminderType: ReminderType = .regular
}

extension Reminder {
  static func groupedByDay(_ reminders: [Reminder]) -> [Reminder] {
    let calendar = Calendar.current
    var groups: [[Reminder]] = []
    var keyToGroupIndex: [String: Int] = [:]

    for reminder in reminders {
      guard let dueDate = reminder.dueDate, reminder.reminderType == .birthday else {
        groups.append([reminder])
        continue
      }
      let key = "birthday|\(Int(calendar.startOfDay(for: dueDate).timeIntervalSinceReferenceDate))"
      if let idx = keyToGroupIndex[key] {
        groups[idx].append(reminder)
      } else {
        keyToGroupIndex[key] = groups.count
        groups.append([reminder])
      }
    }

    return groups.map { $0.count > 1 ? merged(from: $0) : $0[0] }
  }

  private static func merged(from reminders: [Reminder]) -> Reminder {
    var base = reminders[0]
    let titles = reminders.map(\.title)
    base.title = titles.count == 2
      ? "\(titles[0]) & \(titles[1])"
      : "\(titles[0]), \(titles[1]) & \(titles.count - 2) more"
    base.isFlagged = reminders.contains { $0.isFlagged }
    base.tags = Array(Set(reminders.flatMap(\.tags)))
    let nonZero = reminders.compactMap { $0.priority > 0 ? $0.priority : nil }
    base.priority = nonZero.min() ?? 0
    return base
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
