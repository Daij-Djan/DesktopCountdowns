//
//  CountdownsTimelineProvider.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.05.26.
//

import WidgetKit

let kIntervalMinutes = 30

struct CountdownsTimelineProvider: TimelineProvider {
  struct Entry: TimelineEntry {
    let date: Date
    let reminders: [Reminder]
  }

  private let store = ReminderStore.shared
  private let fetchOptions = FetchOptions(onlyWithDueDate: true, orderByDueDate: true)

  func placeholder(in _: Context) -> Self.Entry {
    Self.Entry(date: .now, reminders: Reminder.sampleData)
  }

  func getSnapshot(in context: Context, completion: @escaping (Self.Entry) -> Void) {
    if context.isPreview {
      completion(Self.Entry(date: .now, reminders: Reminder.sampleData))
      return
    }
    store.readAll(with: fetchOptions) { reminders in
      completion(Self.Entry(date: .now, reminders: reminders))
    }
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Self.Entry>) -> Void) {
    store.readAll(with: fetchOptions) { reminders in
      let entry = Self.Entry(date: .now, reminders: reminders)
      let nextUpdate = Calendar.current.date(byAdding: .minute, value: kIntervalMinutes, to: .now) ?? .now
      completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
  }
}
