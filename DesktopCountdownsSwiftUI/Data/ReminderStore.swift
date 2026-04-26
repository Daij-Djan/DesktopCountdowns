//
//  ReminderStore.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 24.05.23.
//
import Foundation

final class ReminderStore {
  protocol BackingStore {
    var isAvailable: Bool { get }

    func readAll(with fetchOptions: FetchOptions, completion: @escaping ([Reminder]) -> Void)
    func addChangeObserver(handler: @escaping  () -> Void) -> NSObjectProtocol?
  }

  static let shared = ReminderStore()
#if canImport(EventKit)
  private let engine: BackingStore? = EventKitReminderStoreBackingStore()
#else
  private let engine: BackingStore? = nil
#endif

  var isAvailable: Bool {
    engine?.isAvailable ?? false
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
    #if DEBUG
    let sampleData = Self.getSampleData(for: fetchOptions)
    if sampleData.isEmpty == false {
      DispatchQueue.main.async {
        completion(sampleData)
      }
      return
    }
    #endif

    engine?.readAll(with: fetchOptions) { reminders in
      let finalReminders = Self.filterAndSortReminders(reminders, with: fetchOptions)
      DispatchQueue.main.async {
        completion(finalReminders)
      }
    }
  }

  func addChangeObserver(handler: @escaping () -> Void) -> NSObjectProtocol {
    let token = engine?.addChangeObserver(handler: handler)
    return token ?? "" as NSObjectProtocol
  }
}

// MARK: SampleData for developing
#if DEBUG
extension ReminderStore {
  private static func getSampleData(for fetchOptions: FetchOptions) -> [Reminder] {
    if fetchOptions.debugUsesSamleData, DeveloperUtils.isDebuggerAttached() {
      print("[DEBUG] useSampleData")
      var reminders = Reminder.sampleData
      if fetchOptions.onlyWithDueDate {
        reminders = reminders.filter { $0.dueDate != nil }
      }
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
    return []
  }
}
#endif
