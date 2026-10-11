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
      Section("Reminders") {
        ForEach(model.reminders) { reminder in
          Button(Self.menuItemTitle(for: reminder)) {
            Self.open(reminder)
          }
        }
      }
      .debugLog("menu body: \(model.reminders.count) reminders")

      if !model.reminders.isEmpty {
        Divider()
      }

      Button("Manage...") {
        Self.openRemindersApp()
      }
      .keyboardShortcut("r")

      Button("Settings...") {
        openSettings()
        NSApp.activate(ignoringOtherApps: true)
      }
      .keyboardShortcut(",")

      Button("Quit") {
        NSApp.terminate(nil)
      }
      .keyboardShortcut("q")
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

    /// opens the reminder (or calendar event) itself via the undocumented Reminders / Calendar URL schemes
    private static func open(_ reminder: Reminder) {
      let encodedId = reminder.id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? reminder.id
      let urlString: String
      switch reminder.reminderType {
      case .regular:
        urlString = "x-apple-reminderkit://REMCDReminder/\(encodedId)"
      case .birthday, .calendar:
        urlString = "ical://ekevent/\(encodedId)?method=show&options=more"
      }
      guard let url = URL(string: urlString), NSWorkspace.shared.open(url) else {
        DebugLog.log("opening \(urlString) failed, falling back to the Reminders app")
        openRemindersApp()
        return
      }
      DebugLog.log("opened \(urlString)")
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
      .debugLog("menu bar label body: \(model.reminders.count)")
    }
  }

  @ObservedObject var model: Model

  var body: some Scene {
    MenuBarExtra(isInserted: model.statusBarItemEnabledBinding) {
      StatusBarMenu(model: model)
    } label: {
      MenuBarLabel(model: model)
    }
    .menuBarExtraStyle(.menu)
    .debugLog("MenuBarExtra scene body: inserted=\(model.statusBarItemEnabled)")
  }
}
#endif
