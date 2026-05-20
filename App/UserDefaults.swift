//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import SwiftUI

extension UserDefaults {
  enum Key {
    static let firstRun = "firstRun"

    static let onlyWithDueDate = "onlyWithDueDate"
    static let orderByDueDate = "orderByDueDate"
    static let includeBirthdays = "includeBirthdays"
    static let birthdayDays = "birthdayDays"

    static let opacity = "opacity"
    static let direction = "direction"
    static let darkenColorByDueDate = "darkenColorByDueDate"
    static let fadeColorByDueDate = "fadeColorByDueDate"
    static let showHoursIfLessThanADay = "showHoursIfLessThanADay"
    static let highpriColor = "highpriColor"
    static let midpriColor = "midpriColor"
    static let lowpriColor = "lowpriColor"
    static let defaultColor = "defaultColor"
    static let birthdayColor = "birthdayColor"

    static let dockIcon = "dockIcon"
    static let statusBarItem = "statusBarItem"
    static let openAtLogin = "openAtLogin"
    static let enabledLauncherId = "enabledLauncher"

    // yes enum would be nice
    static let all = [
      firstRun,
      onlyWithDueDate,
      orderByDueDate,
      includeBirthdays,
      birthdayDays,
      opacity,
      direction,
      darkenColorByDueDate,
      fadeColorByDueDate,
      showHoursIfLessThanADay,
      highpriColor,
      midpriColor,
      lowpriColor,
      defaultColor,
      birthdayColor,
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

  var includeBirthdays: Bool {
    bool(forKey: Key.includeBirthdays)
  }

  var birthdayDays: Int {
    integer(forKey: Key.birthdayDays)
  }

  var opacity: CGFloat {
    // interface builder uses 0-100 for slider, CALayer uses 0-1 for opacity
    CGFloat(float(forKey: Key.opacity) / 100.0)
  }

  var direction: ViewOptions.FlowDirection {
    // swiftlint:disable force_unwrapping
    // we control the enum and the integer, the raw value cant be anything but a valid enum
    ViewOptions.FlowDirection(rawValue: integer(forKey: Key.direction))!
    // swiftlint:enable force_unwrapping
  }

  var darkenColorByDueDate: Bool {
    bool(forKey: Key.darkenColorByDueDate)
  }

  var fadeColorByDueDate: Bool {
    bool(forKey: Key.fadeColorByDueDate)
  }

  var showHoursIfLessThanADay: Bool {
    bool(forKey: Key.showHoursIfLessThanADay)
  }

  var highpriColor: Color {
    color(forKey: Key.highpriColor) ?? ViewOptions.default.highpriColor
  }

  var midpriColor: Color {
    color(forKey: Key.midpriColor) ?? ViewOptions.default.midpriColor
  }

  var lowpriColor: Color {
    color(forKey: Key.lowpriColor) ?? ViewOptions.default.lowpriColor
  }

  var defaultColor: Color {
    color(forKey: Key.defaultColor) ?? ViewOptions.default.defaultColor
  }

  var birthdayColor: Color {
    color(forKey: Key.birthdayColor) ?? ViewOptions.default.birthdayColor
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
    let values1: [String: Any] = [
      Key.firstRun: true,

      Key.orderByDueDate: FetchOptions.default.orderByDueDate,
      Key.onlyWithDueDate: FetchOptions.default.onlyWithDueDate,
      Key.includeBirthdays: FetchOptions.default.includeBirthdays,
      Key.birthdayDays: FetchOptions.default.birthdayDays,

      // interface builder uses 0-100 for slider, CALayer uses 0-1 for opacity
      Key.opacity: ViewOptions.default.opacity * 100,
      Key.direction: ViewOptions.default.direction.rawValue,
      Key.darkenColorByDueDate: ViewOptions.default.darkenColorByDueDate,
      Key.fadeColorByDueDate: ViewOptions.default.fadeColorByDueDate,
      Key.showHoursIfLessThanADay: ViewOptions.default.showHoursIfLessThanADay,

      Key.highpriColor: ViewOptions.default.highpriColor.rawValue,
      Key.midpriColor: ViewOptions.default.midpriColor.rawValue,
      Key.lowpriColor: ViewOptions.default.lowpriColor.rawValue,
      Key.defaultColor: ViewOptions.default.defaultColor.rawValue,
      Key.birthdayColor: ViewOptions.default.birthdayColor.rawValue
    ]
    #if canImport(AppKit)
      let values2: [String: Any] = [
        Key.dockIcon: AppOptions.default.dockIcon,
        Key.statusBarItem: AppOptions.default.statusBarItem,
        Key.openAtLogin: AppOptions.default.openAtLogin
      ]
    let values = values1.merging(values2) { _, new in new }

    #else
      let values = values1
    #endif
    self.register(defaults: values)
  }
}
