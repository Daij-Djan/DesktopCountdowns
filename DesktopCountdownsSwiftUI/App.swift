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
    WindowGroup {
#if os(macOS)
      RemindersList(model: appDelegate.model)
#else
      NavigationStack {
        RemindersList(model: appDelegate.model)
      }
#endif
    }
#if os(macOS)
    Settings {
      PreferencesView()
    }
#endif
  }
}
