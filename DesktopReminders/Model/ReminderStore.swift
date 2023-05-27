//
//  ReminderStore.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 24.05.23.
//

import EventKit
import Foundation

final class ReminderStore {
  static let shared = ReminderStore()
  private let ekStore = EKEventStore()

  var isAvailable: Bool {
    EKEventStore.authorizationStatus(for: .reminder) == .authorized
  }

  func readAll(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    if isAvailable {
      self.readAllAuthorized(with: fetchOptions, completion: completion)
    } else {
      ekStore.requestAccess(to: .reminder) { granted, error in
        if granted {
          self.readAllAuthorized(with: fetchOptions, completion: completion)
        } else {
          print("\(String(describing: error))")
          DispatchQueue.main.async {
            completion([])
          }
        }
      }
    }
  }

  private func readAllAuthorized(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void) {
    let predicate = fetchOptions.onlyIncomplete ? ekStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil) : ekStore.predicateForReminders(in: nil)

    ekStore.fetchReminders(matching: predicate) { ekReminders in
      #if DEBUG
      print("Fetching reminder sample data, NOT using EventKit!")
      var reminders = Reminder.sampleData
      #else
      var reminders = (ekReminders ?? []).map { ekReminder in
        Reminder(with: ekReminder)
      }
      #endif
      
      // filter
      if fetchOptions.onlyWithDueDate {
        reminders = reminders.filter { reminder in
          reminder.dueDate != nil
        }
      }
      // sort
      if fetchOptions.orderByDueDate {
        reminders.sort { reminderA, reminderB in
          if let dueDateA = reminderA.dueDate, let dueDateB = reminderB.dueDate {
            return dueDateA < dueDateB
          }
          return reminderA.dueDate == nil
        }
      }

      DispatchQueue.main.async {
        completion(reminders)
      }
    }
  }
}

extension ReminderStore {
  typealias ChangeHandler = () -> Void

  func addChangeObserver(handler: @escaping ChangeHandler) -> NSObjectProtocol {
    return NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: ekStore, queue: nil) { _ in
      handler()
    }
  }
}
