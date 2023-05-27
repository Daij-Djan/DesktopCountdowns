//
//  UserDefaultsUtils.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 7/1/20.
//

import AppKit

extension UserDefaults {
  fileprivate struct Key {
    static let firstRun = "firstRun"

    static let onlyWithDueDate = "onlyWithDueDate"
    static let orderByDueDate = "orderByDueDate"

    static let opacity = "opacity"
    static let direction = "direction"
    static let darkenColorsByDueDate = "darkenColorsByDueDate"
    static let highpriColor = "highpriColor"
    static let midpriColor = "midpriColor"
    static let lowpriColor = "lowpriColor"
    static let defaultColor = "defaultColor"

    static let dockIcon = "dockIcon"
    static let statusBarItem = "statusBarItem"
    static let openAtLogin = "openAtLogin"
    static let enabledLauncherId = "enabledLauncher"

    //yes enum would be nice
    static let all = [firstRun,
                      onlyWithDueDate,
                      orderByDueDate,
                      opacity,
                      direction,
                      darkenColorsByDueDate,
                      highpriColor,
                      midpriColor,
                      lowpriColor,
                      defaultColor,
                      dockIcon,
                      statusBarItem,
                      openAtLogin,
                      enabledLauncherId]
  }

  var firstRun: Bool {
    get {
      return bool(forKey: Key.firstRun)
    }
    set {
      setValue(newValue, forKey: Key.firstRun)
    }
  }
  
  var onlyWithDueDate: Bool {
    return bool(forKey: Key.onlyWithDueDate)
  }
  
  var orderByDueDate: Bool {
    return bool(forKey: Key.orderByDueDate)
  }
  
  var opacity: Float {
    return float(forKey: Key.opacity) / 100.0
  }

  var direction: RemindersViewController.FlowDirection {
    return RemindersViewController.FlowDirection(rawValue: integer(forKey: Key.direction))!
  }
  
  var darkenColorsByDueDate: Bool {
    return bool(forKey: Key.darkenColorsByDueDate)
  }
 
  var highpriColor: NSColor {
    return color(forKey: Key.highpriColor) ?? ViewOptions.default.highpriColor
  }
  
  var midpriColor: NSColor {
    return color(forKey: Key.midpriColor) ?? ViewOptions.default.midpriColor
  }
  
  var lowpriColor: NSColor {
    return color(forKey: Key.lowpriColor) ?? ViewOptions.default.lowpriColor
  }
  
  var defaultColor: NSColor {
    return color(forKey: Key.defaultColor) ?? ViewOptions.default.defaultColor
  }

  var dockIcon: Bool {
    return bool(forKey: Key.dockIcon)
  }

  var statusBarItem: Bool {
    if !dockIcon {
      return true
    }
    return bool(forKey: Key.statusBarItem)
  }
  
  var openAtLogin: Bool {
    return bool(forKey: Key.openAtLogin)
  }

  var enabledLauncherId: String? {
    get {
      return string(forKey: Key.enabledLauncherId)
    }
    set {
      if newValue != nil {
        setValue(newValue, forKey: Key.enabledLauncherId)
      } else {
        removeObject(forKey: Key.enabledLauncherId)
      }
    }
  }

  func applyInitialValues() {
    self.register(defaults: [
      Key.firstRun: true,

      Key.orderByDueDate: FetchOptions.default.orderByDueDate,
      Key.onlyWithDueDate: FetchOptions.default.onlyWithDueDate,

      Key.opacity: ViewOptions.default.opacity * 100,
      Key.direction: ViewOptions.default.direction.rawValue,
      Key.darkenColorsByDueDate: ViewOptions.default.darkenColorsByDueDate,
      Key.highpriColor: data(forColor: ViewOptions.default.highpriColor),
      Key.midpriColor: data(forColor: ViewOptions.default.midpriColor),
      Key.lowpriColor: data(forColor: ViewOptions.default.lowpriColor),
      Key.defaultColor: data(forColor: ViewOptions.default.defaultColor),

      Key.dockIcon : AppOptions.default.dockIcon,
      Key.statusBarItem : AppOptions.default.statusBarItem,
      Key.openAtLogin : AppOptions.default.openAtLogin,
      //Key.enabledLauncherId = nil
    ])
  }
}

extension UserDefaults {
  typealias ChangeHandler = (_ keyPath: String?) -> Void
  
  fileprivate static var storages = [UnsafeMutablePointer<ChangeHandler>]()

  func addKeysObserver(handler: @escaping ChangeHandler) -> Void {
    let storage = UnsafeMutablePointer<ChangeHandler>.allocate(capacity: 1)
    storage.initialize(to: handler)
    
    UserDefaults.storages.append(storage)
    
    for key in Key.all {
      self.addObserver(self, forKeyPath: key, options: [.initial, .new], context: storage)
    }
  }
  
  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    let handler = context.unsafelyUnwrapped.assumingMemoryBound(to: ChangeHandler.self).pointee
    handler(keyPath)
  }
}

fileprivate extension UserDefaults {
  func color(forKey key: String) -> NSColor? {
    guard let data = data(forKey: key) else {
      return nil
    }
    do {
      return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) as NSColor?
    } catch {
      return nil
    }
  }
  
  func data(forColor color: NSColor) -> Data {
    return try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
  }
}
