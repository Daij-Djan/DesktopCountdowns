//
//  DesktopCountdownsApp.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

import SwiftUI

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
#if os(macOS)
// swiftlint:disable:next indentation_width
    Settings {
      PreferencesView()
    }
    MenuBarExtraScene(model: appDelegate.model)
#else
// swiftlint:disable:next indentation_width
    WindowGroup {
      NavigationStack {
        RemindersList(model: appDelegate.model)
      }
    }
#endif
  }
}
