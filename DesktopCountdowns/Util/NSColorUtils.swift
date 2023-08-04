//
//  NSColorUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 24.05.23.
//

import AppKit

// swiftlint:disable no_magic_numbers

extension NSColor {
  convenience init(hex: String) {
    let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
    let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
    let ui64 = UInt64(hexString, radix: 16)
    let value = Int(ui64 ?? 0)
    // #RRGGBB
    var components = (
      R: CGFloat((value >> 16) & 0xff) / 255,
      G: CGFloat((value >> 08) & 0xff) / 255,
      B: CGFloat((value >> 00) & 0xff) / 255,
      a: CGFloat(1)
    )
    if String(hexString).count == 8 {
      // #RRGGBBAA
      components = (
        R: CGFloat((value >> 24) & 0xff) / 255,
        G: CGFloat((value >> 16) & 0xff) / 255,
        B: CGFloat((value >> 08) & 0xff) / 255,
        a: CGFloat((value >> 00) & 0xff) / 255
      )
    }
    self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
  }
  
  func toHex(withAlpha: Bool = false) -> String {
    // swiftlint:disable force_unwrapping
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    self.usingColorSpace(.sRGB)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    // swiftlint:enable force_unwrapping
    
    let values = (
      R: lroundf(Float(red) * 255),
      G: lroundf(Float(green) * 255),
      B: lroundf(Float(blue) * 255),
      A: lroundf(Float(alpha) * 255)
    )
    
    return withAlpha
    ? String(format: "%02lX%02lX%02lX%02lX", values.R, values.G, values.B, values.A)
    : String(format: "%02lX%02lX%02lX", values.R, values.G, values.B, values.A)
  }
}

extension NSColor {
  func lighter(by percentage: CGFloat = 30.0) -> NSColor {
    self.adjust(by: abs(percentage) )
  }
  
  func darker(by percentage: CGFloat = 30.0) -> NSColor {
    self.adjust(by: -1 * abs(percentage) )
  }
  
  func adjust(by percentage: CGFloat = 30.0) -> NSColor {
    // swiftlint:disable force_unwrapping
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    self.usingColorSpace(.sRGB)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return NSColor(
      red: min(red + percentage / 100, 1.0),
      green: min(green + percentage / 100, 1.0),
      blue: min(blue + percentage / 100, 1.0),
      alpha: alpha
    )
    // swiftlint:enable force_unwrapping
  }
}

// swiftlint:enable no_magic_numbers
