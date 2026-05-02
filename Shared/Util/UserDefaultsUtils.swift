//
//  UserDefaultsUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 7/1/20.
//
import SwiftUI

extension UserDefaults {
  func color(forKey key: String) -> Color? {
    guard let b64data = string(forKey: key) else {
      return nil
    }
    return Color(rawValue: b64data)
  }

  func set(_ color: Color, forKey key: String) {
    set(color.rawValue, forKey: key)
  }
}
