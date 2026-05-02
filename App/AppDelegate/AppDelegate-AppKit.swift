//
//  DesktopCountdownsApp.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

#if canImport(AppKit)
import AppKit
import SwiftUI

private let kSettingsDebounceDelay = 0.1

final class AppDelegate: NSObject, NSApplicationDelegate {
  private(set) var model = Model()

  private lazy var reminderStore = ReminderStore.shared
  private var notificationTokens = [NSObjectProtocol]()
  private var wasCalledBefore = false
  private var desktopWindow: DesktopWindow?

  @objc func showPrefs(_: Any) {
    EnvironmentValues().openSettings()
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc func openRemindersApp(_: Any) {
    let reminderAppUrl = URL(fileURLWithPath: "/System/Applications/Reminders.app")
    NSWorkspace.shared.openApplication(at: reminderAppUrl, configuration: NSWorkspace.OpenConfiguration())
  }

  @objc
  func applySettings() {
    let appOptions = AppOptions(from: UserDefaults.standard)
    let fetchOptions = FetchOptions(from: UserDefaults.standard)
    let viewOptions = ViewOptions(from: UserDefaults.standard)

    // apply dock icon
    #if DEBUG
    var dockIcon = appOptions.dockIcon
    if appOptions.debugAlwaysShowsDock, DeveloperUtils.isDebuggerAttached() {
      print("Always showing dockIcon when a debugger is attached.")
      dockIcon = true
    }
    #else
    let dockIcon = appOptions.dockIcon
    #endif
    let newActivationPolicy: NSApplication.ActivationPolicy = dockIcon ? .regular : .accessory
    if !wasCalledBefore || NSApp.activationPolicy() != newActivationPolicy {
      NSApp.setActivationPolicy(newActivationPolicy)
      NSApp.activate(ignoringOtherApps: true)
    }

    // manage Start at Login
    let shouldOpenAtLogin = appOptions.openAtLogin
    if LaunchAtLogin.isEnabled != shouldOpenAtLogin {
      LaunchAtLogin.isEnabled = shouldOpenAtLogin
    }

    // fetch reminders
    reminderStore.readAll(with: fetchOptions) { reminders in
      // update model
      self.model.reminders = reminders
      self.model.viewOptions = viewOptions
      self.model.statusBarItemEnabled = appOptions.statusBarItem
    }

    wasCalledBefore = true
    desktopWindow?.updateFrame()
  }

  func applicationDidFinishLaunching(_: Notification) {
    // for preview mode, we dont want to do anything
    if DeveloperUtils.isInPreviewMode() {
      return
    }

    desktopWindow = DesktopWindow(model: model)
    desktopWindow?.show()

    // prepare settings
    let sel = #selector(applySettings)
    UserDefaults.standard.applyInitialValues()
    UserDefaults.standard.addKeysObserver(forKeys: UserDefaults.Key.all) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }

    // show prefs if needed
    if UserDefaults.standard.firstRun {
      UserDefaults.standard.firstRun = false
      print("Show prefs for first run")
      showPrefs(self)
    }

    // act on day change
    let notificationTokenDayChange = NotificationCenter.default.addObserver(forName: Notification.Name.NSCalendarDayChanged, object: nil, queue: OperationQueue.main) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }

    // act on screen size change
    let notificationTokenScreenSize = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: OperationQueue.main) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }

    // act on reminder change
    let notificationTokenRemindes = reminderStore.addChangeObserver {
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }

    // save tokens for app lifetime
    notificationTokens = [
      notificationTokenDayChange,
      notificationTokenScreenSize,
      notificationTokenRemindes
    ]
  }
}
#endif
