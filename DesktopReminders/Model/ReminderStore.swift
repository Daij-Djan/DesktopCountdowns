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
  
  private static func filterAndSortReminders(_ input: [Reminder], with fetchOptions: FetchOptions) -> [Reminder] {
    var reminders = input
    
    // filter
    if fetchOptions.onlyWithDueDate {
      reminders = reminders.filter { $0.dueDate != nil }
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
    
    return reminders
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
      var mappedReminders = (ekReminders ?? []).map { Reminder(with: $0) }
      #if DEBUG
      if fetchOptions.debugUsesSamleData && DebuggerUtils.isDebuggerAttached() {
        print("Using reminder sample data only as debugger is attached. Toggle in Options!")
        mappedReminders = Reminder.sampleData
      }
      #endif
      let finalReminders = Self.filterAndSortReminders(mappedReminders, with: fetchOptions)
      
      DispatchQueue.main.async {
        completion(finalReminders)
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
