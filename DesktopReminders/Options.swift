//
//  Options.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 25.05.23.
//

import AppKit

struct FetchOptions {
  let onlyWithDueDate: Bool
  let orderByDueDate: Bool
  
  let onlyIncomplete = true
}
extension FetchOptions {
  init(from defaults: UserDefaults) {
    onlyWithDueDate = defaults.onlyWithDueDate
    orderByDueDate = defaults.orderByDueDate
  }
  static var `default` = FetchOptions(onlyWithDueDate: true, orderByDueDate: true)
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
  let itemSize = NSSize(width: 386.0, height: 86.0)
}
extension ViewOptions {
  init(from defaults: UserDefaults) {
    opacity = defaults.opacity
    direction = defaults.direction
    darkenColorsByDueDate = defaults.darkenColorsByDueDate
    highpriColor = defaults.highpriColor
    midpriColor = defaults.midpriColor
    lowpriColor = defaults.lowpriColor
    defaultColor = defaults.defaultColor
  }
  static var `default` = ViewOptions(opacity: 0.8, direction: .flowVertically, darkenColorsByDueDate: true, highpriColor: NSColor(hex: "e53428"), midpriColor: NSColor(hex: "efc000"), lowpriColor: NSColor(hex: "10aa36"), defaultColor: .gray)
}

struct AppOptions {
  let dockIcon: Bool
  let statusBarItem: Bool
  let openAtLogin : Bool
}
extension AppOptions {
  init(from defaults: UserDefaults) {
    dockIcon = defaults.dockIcon
    statusBarItem = defaults.statusBarItem
    openAtLogin = defaults.openAtLogin
  }
  static var `default` = AppOptions(dockIcon: true, statusBarItem: true, openAtLogin: false)
}
