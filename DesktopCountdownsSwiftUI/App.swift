//
//  DesktopCountdownsApp.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

import SwiftUI

#if os(macOS)
private struct MenuBarLabel: View {
  @ObservedObject var model: Model
  var body: some View {
    HStack {
      Image("StatusBarIcon")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 20)
      Text("\(model.reminders.count)")
    }
  }
}
#endif

@main
struct MultiplatformApp: App {
#if os(watchOS)
  @WKApplicationDelegateAdaptor
#elseif canImport(UIKit) && !os(watchOS)
  @UIApplicationDelegateAdaptor
#elseif canImport(AppKit)
  @NSApplicationDelegateAdaptor
#endif
  var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
#if os(macOS)
// swiftlint:disable:next indentation_width
      RemindersList(model: appDelegate.model)
#else
// swiftlint:disable:next indentation_width
      NavigationStack {
        RemindersList(model: appDelegate.model)
      }
#endif
// swiftlint:disable:next indentation_width
    }
#if os(macOS)
// swiftlint:disable:next indentation_width
    Settings {
      PreferencesView()
    }
// swiftlint:disable:next indentation_width
    MenuBarExtra(
      isInserted: Binding(
        get: { appDelegate.model.statusBarItemEnabled },
        set: { newValue in
          DispatchQueue.main.async {
            appDelegate.model.statusBarItemEnabled = newValue
          }
        }
      )
    ) {
      StatusBarMenu(model: appDelegate.model)
    } label: {
      MenuBarLabel(model: appDelegate.model)
    }
    .menuBarExtraStyle(.menu)
#endif
  }
}
