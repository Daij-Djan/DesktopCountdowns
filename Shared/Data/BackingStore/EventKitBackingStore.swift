//
//  EventKitUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 02.02.25.
//

#if canImport(EventKit)
import EventKit

final class EventKitReminderStoreBackingStore: ReminderStore.BackingStore {
  private let ekStore = EKEventStore()

  func readAll(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    if EKEventStore.authorizationStatus(for: .reminder) == .fullAccess {
      readAllAuthorized(with: fetchOptions, completion: completion)
    } else {
      ekStore.requestFullAccessToReminders { [weak self] granted, error in
        guard let self, granted else {
          if let error { print("Error requesting event access for birthdays: \(error)") }
          completion([])
          return
        }
        readAllAuthorized(with: fetchOptions, completion: completion)
      }
    }
  }

  private func readAllAuthorized(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    let predicate = fetchOptions.onlyIncomplete ? ekStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil) : ekStore.predicateForReminders(in: nil)
    let date = Date()

    ekStore.fetchReminders(matching: predicate) { [weak self] ekReminders in
      var mapped = (ekReminders ?? []).map { Reminder(with: $0, for: date) }

      guard let self, fetchOptions.includeBirthdays, fetchOptions.birthdayDays > 0 else {
        DispatchQueue.main.async { completion(mapped) }
        return
      }

      readUpcomingBirthdays(within: fetchOptions.birthdayDays, from: date) { birthdays in
        mapped.append(contentsOf: birthdays)
        DispatchQueue.main.async { completion(mapped) }
      }
    }
  }

  private func readUpcomingBirthdays(within days: Int, from date: Date, completion: @escaping ([Reminder]) -> Void) {
    if EKEventStore.authorizationStatus(for: .event) == .fullAccess {
      completion(fetchBirthdayReminders(within: days, from: date))
    } else {
      ekStore.requestFullAccessToEvents { [weak self] granted, error in
        guard let self, granted else {
          if let error { print("Error requesting event access for birthdays: \(error)") }
          completion([])
          return
        }
        completion(fetchBirthdayReminders(within: days, from: date))
      }
    }
  }

  private func fetchBirthdayReminders(within days: Int, from date: Date) -> [Reminder] {
    let birthdayCalendars = ekStore.calendars(for: .event).filter { $0.type == .birthday }
    guard !birthdayCalendars.isEmpty else {
      return []
    }

    let calendar = Calendar.current
    guard let endDate = calendar.date(byAdding: .day, value: days, to: date) else {
      return []
    }

    let predicate = ekStore.predicateForEvents(withStart: date, end: endDate, calendars: birthdayCalendars)
    return ekStore.events(matching: predicate).map { Reminder(birthday: $0, for: date) }
  }

  func addChangeObserver(handler: @escaping  () -> Void) -> NSObjectProtocol? {
    NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: ekStore, queue: nil) { _ in
      handler()
    }
  }
}

extension Reminder {
  init(birthday event: EKEvent, for date: Date) {
    id = event.eventIdentifier ?? UUID().uuidString
    title = event.title ?? ""
    dueDate = event.startDate
    dueDateHasTime = false
    if let dueDate {
      countDownDays = dueDate.daysBetween(date)
      countDownHours = dueDate.hoursBetween(date)
    }
    isComplete = false
    priority = 0
    reminderType = .birthday
  }

  init(with ekReminder: EKReminder, for date: Date) {
    id = ekReminder.calendarItemIdentifier
    title = ekReminder.title
    dueDate = ekReminder.dueDateComponents?.date ?? ekReminder.alarms?.first?.absoluteDate
    if let dueDate {
      let comps = Calendar.current.dateComponents([.hour, .minute], from: dueDate)
      dueDateHasTime = (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0
      countDownDays = dueDate.daysBetween(date)
      countDownHours = dueDate.hoursBetween(date)
    }
    isComplete = ekReminder.isCompleted
    priority = ekReminder.priority

    let fields = ekReminder.remPrivateFields
    tags = fields.tags
    isFlagged = fields.isFlagged
    attachmentImageURLs = fields.attachmentImageURLs
  }
}
#endif
