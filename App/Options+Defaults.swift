//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import SwiftUI

// swiftlint:disable no_magic_numbers

extension FetchOptions {
  static var `default` = FetchOptions(
    onlyWithDueDate: true,
    orderByDueDate: true
  )

  init(from defaults: UserDefaults) {
    onlyWithDueDate = defaults.onlyWithDueDate
    orderByDueDate = defaults.orderByDueDate
  }
}

extension ViewOptions {
  static var `default` = ViewOptions(
    opacity: 0.9,
    direction: .flowVertically,
    darkenColorByDueDate: true,
    fadeColorByDueDate: true,
    highpriColor: Color(hex: "e53428"),
    midpriColor: Color(hex: "fed200"),
    lowpriColor: Color(hex: "10aa36"),
    defaultColor: Color(hex: "929292")
  )

  init(from defaults: UserDefaults) {
    opacity = defaults.opacity
    direction = defaults.direction
    darkenColorByDueDate = defaults.darkenColorByDueDate
    fadeColorByDueDate = defaults.fadeColorByDueDate
    highpriColor = defaults.highpriColor
    midpriColor = defaults.midpriColor
    lowpriColor = defaults.lowpriColor
    defaultColor = defaults.defaultColor
  }
}

#if canImport(AppKit)
extension AppOptions {
  static var `default` = AppOptions(
    dockIcon: true,
    statusBarItem: true,
    openAtLogin: false
  )

  init(from defaults: UserDefaults) {
    dockIcon = defaults.dockIcon
    statusBarItem = defaults.statusBarItem
    openAtLogin = defaults.openAtLogin
  }
}
#endif

// swiftlint:enable no_magic_numbers
