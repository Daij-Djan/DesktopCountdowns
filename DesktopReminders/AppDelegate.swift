//
//  AppDelegate.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa

private let kSettingsDebounceDelay = 0.1

@NSApplicationMain
class AppDelegate: NSObject {
  private lazy var statusBarItemController = StatusBarItemController()
  private lazy var desktopWindowController = DesktopWindowController()
  private lazy var reminderStore = ReminderStore.shared
  
  private var notificationTokens = [NSObjectProtocol]()
  
  @IBOutlet private var prefsWindow: NSWindow!
  
  override init() {
    super.init()
    ValueTransformer.setValueTransformer( NSColorTransformer(), forName: .NSColorTransformerName )
  }
  
  @IBAction func showPrefs(_: Any) {
    NSApp.activate(ignoringOtherApps: true)
    prefsWindow?.makeKeyAndOrderFront(self)
  }
  
  @IBAction func openRemindersApp(_: Any) {
    let reminderAppUrl = URL(fileURLWithPath: "/System/Applications/Reminders.app")
    NSWorkspace.shared.openApplication(at: reminderAppUrl, configuration: NSWorkspace.OpenConfiguration())
  }
  
  @objc
  private func applySettings() {
    let appOptions = AppOptions(from: UserDefaults.standard)
    let fetchOptions = FetchOptions(from: UserDefaults.standard)
    let viewOptions = ViewOptions(from: UserDefaults.standard)
    
    // apply dock icon
    #if DEBUG
    var dockIcon = appOptions.dockIcon
    if DebuggerUtils.isDebuggerAttached() {
      print("Always showing dockIcon when a debugger is attached")
      dockIcon = true
    }
    #else
    let dockIcon = appOptions.dockIcon
    #endif
    NSApp.setActivationPolicy(dockIcon ? .regular : .accessory)
    NSApp.activate(ignoringOtherApps: true)
    
    // manage Start at Login
    let shouldOpenAtLogin = appOptions.openAtLogin
    if LaunchAtLogin.isEnabled != shouldOpenAtLogin {
      LaunchAtLogin.isEnabled = shouldOpenAtLogin
    }
    
    // fetch reminders
    reminderStore.readAll(with: fetchOptions) { reminders in
      // update statusbar
      self.statusBarItemController.reminders = reminders
      self.statusBarItemController.enabled = appOptions.statusBarItem
      
      // update desktop window
      self.desktopWindowController.reminders = reminders
      self.desktopWindowController.viewOptions = viewOptions
    }
  }
}

extension AppDelegate: NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // prepare our UI Windows
    statusBarItemController.menu = NSApp.mainMenu?.items.first?.submenu
    desktopWindowController.enabled = true
    
    // Workaround for dock icon visibility toggle: osx hides our windows on becoming .accessory. dont let it
    for window in NSApp.windows {
      window.canHide = false
    }
    
    // prepare settings
    let sel = #selector(applySettings)
    UserDefaults.standard.applyInitialValues()
    UserDefaults.standard.addKeysObserver { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }
    
    // show prefs if needed
    if UserDefaults.standard.firstRun {
      UserDefaults.standard.firstRun = false
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
