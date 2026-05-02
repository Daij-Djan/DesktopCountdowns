//
//  UserDefaultsUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 7/1/20.
//
import SwiftUI

extension UserDefaults {
  func color(forKey key: String) -> Color? {
    guard let hex = string(forKey: key) else {
      return nil
    }
    return Color(hex: hex)
  }

  func set(_ color: Color, forKey key: String) {
    set(color.hex, forKey: key)
  }
}
