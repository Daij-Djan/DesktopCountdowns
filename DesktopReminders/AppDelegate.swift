//
//  AppDelegate.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa

let settingsDebounceDelay = 0.1

@NSApplicationMain
class AppDelegate: NSObject {
  @IBOutlet private var prefsWindow: NSWindow!
  private lazy var statusBarItemController = StatusBarItemController()
  private lazy var desktopWindowController = DesktopWindowController()
  private lazy var reminderStore = ReminderStore.shared
  
  override init() {
      super.init()
      ValueTransformer.setValueTransformer( NSColorTransformer(), forName: .NSColorTransformerName )
  }

  @IBAction private func showPrefs(_:Any) {
    NSApp.activate(ignoringOtherApps: true)
    prefsWindow?.makeKeyAndOrderFront(self)
  }
  
  @objc private func applySettings() {
    let appOptions = AppOptions(from: UserDefaults.standard)
    let fetchOptions = FetchOptions(from: UserDefaults.standard)
    let viewOptions = ViewOptions(from: UserDefaults.standard)
    
    //apply dock icon
    NSApp.setActivationPolicy(appOptions.dockIcon ? .regular : .accessory)
    NSApp.activate(ignoringOtherApps: true)
        
    //manage Start at Login
    let shouldOpenAtLogin = appOptions.openAtLogin
    if LaunchAtLogin.isEnabled != shouldOpenAtLogin {
      LaunchAtLogin.isEnabled = shouldOpenAtLogin
    }
      
    //fetch reminders
    reminderStore.readAll(with: fetchOptions) { reminders in
      //update statusbar
      self.statusBarItemController.reminders = reminders
      self.statusBarItemController.enabled = appOptions.statusBarItem
      
      //update desktop window
      self.desktopWindowController.reminders = reminders
      self.desktopWindowController.viewOptions = viewOptions
    }
  }
}

extension AppDelegate: NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    //prepare our UI Windows
    statusBarItemController.menu = NSApp.mainMenu?.items.first?.submenu
    desktopWindowController.enabled = true

    //Workaround for dock icon visibility toggle: osx hides our windows on becoming .accessory. dont let it
    for window in NSApp.windows {
      window.canHide = false
    }
    
    //prepare settings
    let sel = #selector(applySettings)
    UserDefaults.standard.applyInitialValues()
    UserDefaults.standard.addKeysObserver { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: settingsDebounceDelay)
    }
    
    //show prefs if needed
    if UserDefaults.standard.firstRun {
      UserDefaults.standard.firstRun = false
      showPrefs(self)
    }
    
    //act on day change
    NotificationCenter.default.addObserver(forName: NSNotification.Name.NSCalendarDayChanged, object: nil, queue: OperationQueue.main) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: settingsDebounceDelay)
    }

    //act on screen size change
    NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: OperationQueue.main) { _ in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: settingsDebounceDelay)
    }
    
    //act on reminder change
    reminderStore.addChangeObserver {
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: settingsDebounceDelay)
    }
  }
}
