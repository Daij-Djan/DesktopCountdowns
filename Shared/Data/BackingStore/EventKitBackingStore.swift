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

  var isAvailable: Bool {
    EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
  }

  func readAll(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    if isAvailable {
      self.readAllAuthorized(with: fetchOptions, completion: completion)
    } else {
      ekStore.requestFullAccessToReminders { granted, error in
        if granted {
          self.readAllAuthorized(with: fetchOptions, completion: completion)
        } else {
          print("Error requesting access to EKStore: \(String(describing: error))")
          DispatchQueue.main.async {
            completion([])
          }
        }
      }
    }
  }

  private func readAllAuthorized(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    let predicate = fetchOptions.onlyIncomplete ? ekStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil) : ekStore.predicateForReminders(in: nil)
    let date = Date()

    ekStore.fetchReminders(matching: predicate) { [weak self] ekReminders in
      var mapped = (ekReminders ?? []).map { Reminder(with: $0, for: date) }

      guard let self, fetchOptions.includeBirthdaysThisMonth else {
        DispatchQueue.main.async { completion(mapped) }
        return
      }

      self.readBirthdaysThisMonth(from: date) { birthdays in
        mapped.append(contentsOf: birthdays)
        DispatchQueue.main.async { completion(mapped) }
      }
    }
  }

  private func readBirthdaysThisMonth(from date: Date, completion: @escaping ([Reminder]) -> Void) {
    if EKEventStore.authorizationStatus(for: .event) == .fullAccess {
      completion(fetchBirthdayReminders(from: date))
    } else {
      ekStore.requestFullAccessToEvents { [weak self] granted, error in
        guard let self, granted else {
          if let error { print("Error requesting event access for birthdays: \(error)") }
          completion([])
          return
        }
        completion(self.fetchBirthdayReminders(from: date))
      }
    }
  }

  private func fetchBirthdayReminders(from date: Date) -> [Reminder] {
    let birthdayCalendars = ekStore.calendars(for: .event).filter { $0.type == .birthday }
    guard !birthdayCalendars.isEmpty else { return [] }

    let calendar = Calendar.current
    let comps = calendar.dateComponents([.year, .month], from: date)
    guard let firstOfMonth = calendar.date(from: comps),
          let firstOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth) else {
      return []
    }

    let predicate = ekStore.predicateForEvents(withStart: date, end: firstOfNextMonth, calendars: birthdayCalendars)
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
    }
    isComplete = false
    priority = 0
  }

  init(with ekReminder: EKReminder, for date: Date) {
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
      countDownDays = dueDate.daysBetween(date)
    }
    isComplete = ekReminder.isCompleted
    priority = ekReminder.priority
  }
}
#endif
