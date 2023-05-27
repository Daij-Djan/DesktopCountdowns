//
//  main.swift
//  DesktopRemindersLauncher
//
//  Created by Dominik Pich on 7/1/20.
//

import Cocoa

//MARK: constants
fileprivate let mainBundleId = Bundle.main.bundleIdentifier!.replacingOccurrences(of: "-launcher", with: "")

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Ensure the app is not already running
    guard NSRunningApplication.runningApplications(withBundleIdentifier: mainBundleId).isEmpty else {
      NSApp.terminate(nil)
      return
    }
    
    let pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
    let mainPath = NSString.path(withComponents: Array(pathComponents[0...(pathComponents.count - 5)]))
    NSWorkspace.shared.launchApplication(mainPath)
    NSApp.terminate(nil)
  }
}

//MARK: entry point
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

