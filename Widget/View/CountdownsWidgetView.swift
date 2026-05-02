//
//  CountdownsWidgetView.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.05.26.
//

import SwiftUI
import WidgetKit

// swiftlint:disable no_magic_numbers
struct CountdownsWidgetView: View {
  var entry: CountdownsTimelineProvider.Entry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    default:
      largeView
    }
  }

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 6) {
      if let first = entry.reminders.first {
        CountdownsWidgetItem(reminder: first)
      } else {
        emptyView
      }
    }
  }

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 4) {
      ForEach(entry.reminders.prefix(3)) { reminder in
        CountdownsWidgetItem(reminder: reminder)
        if reminder.id != entry.reminders.prefix(3).last?.id {
          Divider()
        }
      }
      if entry.reminders.isEmpty {
        emptyView
      }
    }
  }

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 4) {
      ForEach(entry.reminders.prefix(6)) { reminder in
        CountdownsWidgetItem(reminder: reminder)
        if reminder.id != entry.reminders.prefix(6).last?.id {
          Divider()
        }
      }
      if entry.reminders.isEmpty {
        emptyView
      }
      Spacer()
    }
  }

  private var emptyView: some View {
    VStack {
      Spacer()
      Text("No upcoming reminders")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}
// swiftlint:enable no_magic_numbers
