//
//  main.swift
//  DesktopRemindersLauncher
//
//  Created by Dominik Pich on 7/1/20.
//

import Cocoa

// MARK: constants

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // swiftlint:disable force_unwrapping
    // if the main bundle identifier is nil, we are screwed so force cating wont hurt
    let mainBundleId = Bundle.main.bundleIdentifier!.replacingOccurrences(of: "-launcher", with: "")
    // swiftlint:enable force_unwrapping

    // Ensure the app is not already running
    guard NSRunningApplication.runningApplications(withBundleIdentifier: mainBundleId).isEmpty else {
      NSApp.terminate(nil)
      return
    }

    // swiftlint:disable legacy_objc_type
    // swiftlint:disable no_magic_numbers
    // This string manipulation becomes tedious with urls
    let pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
    let mainPath = NSString.path(withComponents: Array(pathComponents[0...(pathComponents.count - 5)]))
    // swiftlint:enable no_magic_numbers
    // swiftlint:enable legacy_objc_type
    NSWorkspace.shared.launchApplication(mainPath)
    NSApp.terminate(nil)
  }
}

// MARK: entry point
private let kAppDelegate = AppDelegate()

NSApplication.shared.delegate = kAppDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
