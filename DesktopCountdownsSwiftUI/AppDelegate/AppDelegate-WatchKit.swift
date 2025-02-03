//
//  DesktopCountdownsApp.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

#if os(watchOS)
import WatchKit

private let kSettingsDebounceDelay = 0.1

final class AppDelegate: NSObject, WKApplicationDelegate {
  private(set) var model = Model()
  
  private lazy var reminderStore = ReminderStore.shared
  private var notificationTokens = [NSObjectProtocol]()
  private var wasCalledBefore = false
  
  @IBAction func showPrefs(_: Any) {
    // TODO
  }
  
  @IBAction func openRemindersApp(_: Any) {
    // TODO
  }
  
  @objc
  func applySettings() {
    let fetchOptions = FetchOptions(from: UserDefaults.standard)
    let viewOptions = ViewOptions(from: UserDefaults.standard)
        
    // fetch reminders
    reminderStore.readAll(with: fetchOptions) { reminders in
      // update subscription
      self.model.reminders = reminders
      self.model.viewOptions = viewOptions
    }
    
    wasCalledBefore = true
  }
  
  func applicationDidFinishLaunching() {
    // for preview mode, we dont want to do anything
    if DeveloperUtils.isInPreviewMode() {
      return
    }
 
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
    
    // act on reminder change
    let notificationTokenRemindes = reminderStore.addChangeObserver {
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(sel, with: nil, afterDelay: kSettingsDebounceDelay)
    }
    
    // save tokens for app lifetime
    notificationTokens = [
      notificationTokenDayChange,
      notificationTokenRemindes
    ]
  }
}
#endif
