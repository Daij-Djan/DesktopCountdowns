//
//  UserDefaultsUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 7/1/20.
//

import AppKit

extension UserDefaults {
  private struct Key {
    static let firstRun = "firstRun"

    static let onlyWithDueDate = "onlyWithDueDate"
    static let orderByDueDate = "orderByDueDate"

    static let opacity = "opacity"
    static let direction = "direction"
    static let darkenColorByDueDate = "darkenColorByDueDate"
    static let fadeColorByDueDate = "fadeColorByDueDate"
    static let highpriColor = "highpriColor"
    static let midpriColor = "midpriColor"
    static let lowpriColor = "lowpriColor"
    static let defaultColor = "defaultColor"

    static let dockIcon = "dockIcon"
    static let statusBarItem = "statusBarItem"
    static let openAtLogin = "openAtLogin"
    static let enabledLauncherId = "enabledLauncher"

    // yes enum would be nice
    static let all = [
      firstRun,
      onlyWithDueDate,
      orderByDueDate,
      opacity,
      direction,
      darkenColorByDueDate,
      fadeColorByDueDate,
      highpriColor,
      midpriColor,
      lowpriColor,
      defaultColor,
      dockIcon,
      statusBarItem,
      openAtLogin,
      enabledLauncherId
    ]
  }

  var firstRun: Bool {
    get {
      bool(forKey: Key.firstRun)
    }
    set {
      setValue(newValue, forKey: Key.firstRun)
    }
  }

  var onlyWithDueDate: Bool {
    bool(forKey: Key.onlyWithDueDate)
  }

  var orderByDueDate: Bool {
    bool(forKey: Key.orderByDueDate)
  }

  var opacity: Float {
    // swiftlint:disable no_magic_numbers
    // interface builder uses 0-100 for slider, CALayer uses 0-1 for opacity
    float(forKey: Key.opacity) / 100.0
    // swiftlint:enable no_magic_numbers
  }

  var direction: RemindersViewController.FlowDirection {
    // swiftlint:disable force_unwrapping
    // we control the enum and the integer, the raw value cant be anything but a valid enum
    RemindersViewController.FlowDirection(rawValue: integer(forKey: Key.direction))!
    // swiftlint:enable force_unwrapping
  }

  var darkenColorByDueDate: Bool {
    bool(forKey: Key.darkenColorByDueDate)
  }

  var fadeColorByDueDate: Bool {
    bool(forKey: Key.fadeColorByDueDate)
  }

  var highpriColor: NSColor {
    color(forKey: Key.highpriColor) ?? ViewOptions.default.highpriColor
  }

  var midpriColor: NSColor {
    color(forKey: Key.midpriColor) ?? ViewOptions.default.midpriColor
  }

  var lowpriColor: NSColor {
    color(forKey: Key.lowpriColor) ?? ViewOptions.default.lowpriColor
  }

  var defaultColor: NSColor {
    color(forKey: Key.defaultColor) ?? ViewOptions.default.defaultColor
  }

  var dockIcon: Bool {
    bool(forKey: Key.dockIcon)
  }

  var statusBarItem: Bool {
    if !dockIcon {
      return true
    }
    return bool(forKey: Key.statusBarItem)
  }

  var openAtLogin: Bool {
    bool(forKey: Key.openAtLogin)
  }

  var enabledLauncherId: String? {
    get {
      string(forKey: Key.enabledLauncherId)
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

      // swiftlint:disable no_magic_numbers
      // interface builder uses 0-100 for slider, CALayer uses 0-1 for opacity
      Key.opacity: ViewOptions.default.opacity * 100,
      // swiftlint:enable no_magic_numbers
      Key.direction: ViewOptions.default.direction.rawValue,
      Key.darkenColorByDueDate: ViewOptions.default.darkenColorByDueDate,
      Key.fadeColorByDueDate: ViewOptions.default.fadeColorByDueDate,
      Key.highpriColor: data(forColor: ViewOptions.default.highpriColor),
      Key.midpriColor: data(forColor: ViewOptions.default.midpriColor),
      Key.lowpriColor: data(forColor: ViewOptions.default.lowpriColor),
      Key.defaultColor: data(forColor: ViewOptions.default.defaultColor),

      Key.dockIcon: AppOptions.default.dockIcon,
      Key.statusBarItem: AppOptions.default.statusBarItem,
      Key.openAtLogin: AppOptions.default.openAtLogin
      // Key.enabledLauncherId = nil
    ])
  }
}

extension UserDefaults {
  // swiftlint:disable block_based_kvo
  // swiftlint:disable override_in_extension
  // swiftlint:disable discouraged_optional_collection
  typealias ChangeHandler = (_ keyPath: String?) -> Void

  private static var storages = [UnsafeMutablePointer<ChangeHandler>]()

  func addKeysObserver(handler: @escaping ChangeHandler) {
    let storage = UnsafeMutablePointer<ChangeHandler>.allocate(capacity: 1)
    storage.initialize(to: handler)

    UserDefaults.storages.append(storage)

    for key in Key.all {
      self.addObserver(self, forKeyPath: key, options: [.initial, .new], context: storage)
    }
  }
  
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    let handler = context.unsafelyUnwrapped.assumingMemoryBound(to: ChangeHandler.self).pointee
    handler(keyPath)
  }
  // swiftlint:enable discouraged_optional_collection
  // swiftlint:enable override_in_extension
  // swiftlint:enable block_based_kvo
}

extension UserDefaults {
  private func color(forKey key: String) -> NSColor? {
    guard let data = data(forKey: key) else {
      return nil
    }
    do {
      return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) as NSColor?
    } catch {
      return nil
    }
  }

  private func data(forColor color: NSColor) -> Data {
    // swiftlint:disable force_try
    // - we archive data only from 4 fixed NSColor instances when building our defaults
    return try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    // swiftlint:enable force_try
  }
}
