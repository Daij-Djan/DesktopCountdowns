//
//  StatusBarMenu.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 6/27/20.
//

#if canImport(AppKit)
import SwiftUI

struct StatusBarMenu: View {
  @ObservedObject var model: Model
  @Environment(\.openSettings) private var openSettings

  var body: some View {
    Button("Settings...") {
      openSettings()
      NSApp.activate(ignoringOtherApps: true)
    }
    .keyboardShortcut(",")

    Divider()

    Section("Reminders") {
      ForEach(model.reminders) { reminder in
        Button(Self.menuItemTitle(for: reminder)) {
          Self.openRemindersApp()
        }
      }
    }

    if !model.reminders.isEmpty {
      Divider()
    }

    Button("Manage...") {
      Self.openRemindersApp()
    }
    .keyboardShortcut("r")
  }

  private static func menuItemTitle(for reminder: Reminder) -> String {
    if let dueDate = reminder.dueDate {
      return String(
        format: NSLocalizedString(
          "%@ (%d)...",
          comment: "menu item for reminder with duedate"
        ),
        reminder.title,
        dueDate.daysBetween(Date())
      )
    }

    return String(
      format: NSLocalizedString(
        "%@...",
        comment: "menu item for reminder without duedate"
      ),
      reminder.title
    )
  }

  private static func openRemindersApp() {
    let reminderAppUrl = URL(fileURLWithPath: "/System/Applications/Reminders.app")
    NSWorkspace.shared.openApplication(at: reminderAppUrl, configuration: NSWorkspace.OpenConfiguration())
  }
}
#endif
