//
//  MenuBarExtraScene.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.05.26.
//

import SwiftUI

#if os(macOS)
struct MenuBarExtraScene: Scene {
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

  struct MenuBarLabel: View {
    @ObservedObject var model: Model
    var body: some View {
      HStack {
        Image(.statusBarIcon)
          .accessibilityLabel("Deskop Countdowns")
        Text("\(model.reminders.count)")
      }
    }
  }

  @ObservedObject var model: Model

  var body: some Scene {
    MenuBarExtra(
      isInserted: Binding(
        get: { model.statusBarItemEnabled },
        set: { newValue in
          DispatchQueue.main.async {
            model.statusBarItemEnabled = newValue
          }
        }
      )
    ) {
      StatusBarMenu(model: model)
    } label: {
      MenuBarLabel(model: model)
    }
    .menuBarExtraStyle(.menu)
  }
}
#endif
