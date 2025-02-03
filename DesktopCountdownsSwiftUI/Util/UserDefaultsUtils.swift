//
//  UserDefaultsUtils.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 7/1/20.
//

import SwiftUI

// MARK: easisly observable interface
extension UserDefaults {
  // swiftlint:disable block_based_kvo
  // swiftlint:disable override_in_extension
  // swiftlint:disable discouraged_optional_collection
  typealias ChangeHandler = (_ keyPath: String?) -> Void

  private static var storages = [UnsafeMutablePointer<ChangeHandler>]()

  func addKeysObserver(forKeys keys: [String], handler: @escaping ChangeHandler) {
    let storage = UnsafeMutablePointer<ChangeHandler>.allocate(capacity: 1)
    storage.initialize(to: handler)

    UserDefaults.storages.append(storage)

    for key in keys {
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

// MARK: convenience to store colors
extension UserDefaults {
  func color(forKey key: String) -> Color? {
    guard let data = string(forKey: key) else {
      return nil
    }
    return Color(rawValue: data)
  }
}
