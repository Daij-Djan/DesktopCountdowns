//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import SwiftUI

// swiftlint:disable no_magic_numbers
// swiftlint:disable file_types_order

struct FetchOptions {
  let onlyWithDueDate: Bool
  let orderByDueDate: Bool
  
  let onlyIncomplete = true
#if DEBUG
  let debugUsesSamleData = true
#endif
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
  enum FlowDirection: Int {
    case flowHorizontally = 0
    case flowVertically = 1
  }
  
  let opacity: CGFloat
  let direction: FlowDirection
  let darkenColorByDueDate: Bool
  let fadeColorByDueDate: Bool
  let highpriColor: Color
  let midpriColor: Color
  let lowpriColor: Color
  let defaultColor: Color
  
  let screenFrameInset = 6.0
  let cellSize = CGSize(width: 386.0, height: 86.0)
  let cellCornerRadius = 10.0
#if canImport(AppKit)
  let statusBarIconSize = CGSize(width: 22, height: 22)
  let statusBarFont = Font.system(.body)
  #endif
#if DEBUG
  let debugKeepsWindowMode = true
#endif
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
struct AppOptions {
  let dockIcon: Bool
  let statusBarItem: Bool
  let openAtLogin: Bool
  
#if DEBUG
  let debugAlwaysShowsDock = true
#endif
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
#endif

// swiftlint:enable file_types_order
// swiftlint:enable no_magic_numbers
