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
  private var launchedToOpenReminders = false
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
      if !launchedToOpenReminders {
        NSApp.activate(ignoringOtherApps: true)
      }
      launchedToOpenReminders = false
    }

    // manage Start at Login
    let shouldOpenAtLogin = appOptions.openAtLogin
    if LaunchAtLogin.isEnabled != shouldOpenAtLogin {
      LaunchAtLogin.isEnabled = shouldOpenAtLogin
    }

    // fetch reminders
    reloadReminders()

    wasCalledBefore = true
    desktopWindow?.updateFrame()
  }

  @objc
  func reloadReminders() {
    let appOptions = AppOptions(from: UserDefaults.standard)
    let fetchOptions = FetchOptions(from: UserDefaults.standard)
    let viewOptions = ViewOptions(from: UserDefaults.standard)

    reminderStore.readAll(with: fetchOptions) { reminders in
      // update model, but only publish what actually changed to avoid needless UI rebuilds
      let newReminders = viewOptions.groupByDay ? Reminder.groupedByDay(reminders) : reminders
      if self.model.reminders != newReminders {
        self.model.reminders = newReminders
      }
      if self.model.viewOptions != viewOptions {
        self.model.viewOptions = viewOptions
      }
      if self.model.statusBarItemEnabled != appOptions.statusBarItem {
        self.model.statusBarItemEnabled = appOptions.statusBarItem
      }
    }
  }

  func application(_: NSApplication, open urls: [URL]) {
    for url in urls where url.host == "open-reminders" {
      openRemindersApp(self)
    }
  }

  func applicationWillFinishLaunching(_: Notification) {
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleURLEvent(_:withReply:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
  }

  @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, withReply _: NSAppleEventDescriptor) {
    guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString), url.host == "open-reminders" else {
      return
    }
    launchedToOpenReminders = true
  }

  func applicationDidFinishLaunching(_: Notification) {
    #if DEBUG
    // for preview mode, we dont want to do anything
    if DeveloperUtils.isInPreviewMode() {
      return
    }
    #endif

    desktopWindow = DesktopWindow(model: model)
    desktopWindow?.show()

    // restore scoped access to Reminders attachments folder if previously granted and feature is on
    if UserDefaults.standard.showAttachmentImages {
      ScopedAccess.shared.startAccessingIfNeeded()
    }

    // prepare settings
    let sel = #selector(applySettings)
    UserDefaults.standard.applyInitialValues()
    let notificationTokenDefaultsDidChange = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }
    self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)

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

    // act on reminder change; only refetch reminders, the app settings are unaffected
    let reloadSel = #selector(reloadReminders)
    let notificationTokenRemindes = reminderStore.addChangeObserver {
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: reloadSel, object: nil)
      self.perform(reloadSel, with: nil, afterDelay: kSettingsDebounceDelay)
    }

    // reload images immediately after attachments folder access is granted
    let notificationTokenAttachmentsAccess = NotificationCenter.default.addObserver(
      forName: ScopedAccess.accessGrantedNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.model.imageReloadToken = UUID()
    }

    // save tokens for app lifetime
    notificationTokens = [
      notificationTokenDefaultsDidChange,
      notificationTokenDayChange,
      notificationTokenScreenSize,
      notificationTokenRemindes,
      notificationTokenAttachmentsAccess
    ]
  }
}
#endif
