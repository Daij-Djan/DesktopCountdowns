//
//  Options.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 25.05.23.
//

import AppKit

// swiftlint:disable no_magic_numbers
// swiftlint:disable file_types_order

struct FetchOptions {
  let onlyWithDueDate: Bool
  let orderByDueDate: Bool

  let onlyIncomplete = true
}
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

struct ViewOptions {
  let opacity: Float
  let direction: RemindersViewController.FlowDirection
  let darkenColorsByDueDate: Bool
  let highpriColor: NSColor
  let midpriColor: NSColor
  let lowpriColor: NSColor
  let defaultColor: NSColor

  let screenFrameInset = 6.0
  let cellSize = NSSize(width: 386.0, height: 86.0)
  let cellCornerRadius = 10.0
  let statusBarIconSize = NSSize(width: 22, height: 22)
  let statusBarFont = NSFont.systemFont(ofSize: 13)
}
extension ViewOptions {
  static var `default` = ViewOptions(
    opacity: 0.8,
    direction: .flowVertically,
    darkenColorsByDueDate: true,
    highpriColor: NSColor(hex: "e53428"),
    midpriColor: NSColor(hex: "efc000"),
    lowpriColor: NSColor(hex: "10aa36"),
    defaultColor: .gray
  )
  
  init(from defaults: UserDefaults) {
    opacity = defaults.opacity
    direction = defaults.direction
    darkenColorsByDueDate = defaults.darkenColorsByDueDate
    highpriColor = defaults.highpriColor
    midpriColor = defaults.midpriColor
    lowpriColor = defaults.lowpriColor
    defaultColor = defaults.defaultColor
  }
}

struct AppOptions {
  let dockIcon: Bool
  let statusBarItem: Bool
  let openAtLogin: Bool
}
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

// swiftlint:enable file_types_order
// swiftlint:enable no_magic_numbers
