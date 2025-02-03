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
    
    ekStore.fetchReminders(matching: predicate) { ekReminders in
      let mappedReminders = (ekReminders ?? []).map { Reminder(with: $0, for: date) }
      DispatchQueue.main.async {
        completion(mappedReminders)
      }
    }
  }
  
  func addChangeObserver(handler: @escaping  () -> Void) -> NSObjectProtocol? {
    return NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: ekStore, queue: nil) { _ in
      handler()
    }
  }
}

extension Reminder {
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
