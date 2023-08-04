//
//  LaunchAtLoginUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 7/1/20.
//

import Foundation
import ServiceManagement

struct LaunchAtLogin {
  // swiftlint:disable force_unwrapping
  // if the main bundle identifier is nil, we are screwed so force cating wont hurt
  private static let launcherIdentifier = "\(Bundle.main.bundleIdentifier!)-launcher"
  // swiftlint:enable force_unwrapping

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
