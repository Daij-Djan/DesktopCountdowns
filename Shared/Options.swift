//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import SwiftUI

// swiftlint:disable no_magic_numbers
// swiftlint:disable file_types_order
// swiftlint:disable one_declaration_per_file

struct FetchOptions {
  let onlyWithDueDate: Bool
  let orderByDueDate: Bool
  let includeBirthdays: Bool
  let birthdayDays: Int

  let onlyIncomplete = true
#if DEBUG
  let debugUsesSamleData = false
#endif
}

struct ViewOptions: Equatable {
  enum FlowDirection: Int {
    case flowHorizontally = 0
    case flowVertically = 1
  }

  let opacity: CGFloat
  let direction: FlowDirection
  let darkenColorByDueDate: Bool
  let fadeColorByDueDate: Bool
  let showHoursIfLessThanADay: Bool
  let showAttachmentImages: Bool
  let groupByDay: Bool
  let highpriColor: Color
  let midpriColor: Color
  let lowpriColor: Color
  let defaultColor: Color
  let birthdayColor: Color

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

#if canImport(AppKit)
struct AppOptions: Equatable {
  let dockIcon: Bool
  let statusBarItem: Bool
  let openAtLogin: Bool

#if DEBUG
  let debugAlwaysShowsDock = true
#endif
}
#endif

// swiftlint:enable one_declaration_per_file
// swiftlint:enable file_types_order
// swiftlint:enable no_magic_numbers
