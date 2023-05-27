//
//  LaunchAtLoginUtils.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 7/1/20.
//

import Foundation
import ServiceManagement

struct LaunchAtLogin {
  fileprivate static let launcherIdentifier = "\(Bundle.main.bundleIdentifier!)-launcher"

  static var isEnabled: Bool {
    get {
      guard let enabledLauncher = UserDefaults.standard.enabledLauncherId else {
        return false
      }
      return enabledLauncher == launcherIdentifier
    }
    set {
      UserDefaults.standard.enabledLauncherId = newValue ? launcherIdentifier : nil
      SMLoginItemSetEnabled(launcherIdentifier as CFString, newValue)
    }
  }
}
