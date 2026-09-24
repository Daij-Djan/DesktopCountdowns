//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

final class Model: ObservableObject {
  @Published var reminders: [Reminder] = []
  @Published var viewOptions: ViewOptions = .default
  @Published var imageReloadToken = UUID()
#if canImport(AppKit)
  @Published var statusBarItemEnabled = true

  /// The binding handed to `MenuBarExtra(isInserted:)`.
  ///
  /// It is created once and reused: SwiftUI compares a scene body against its predecessor
  /// to decide whether the app graph settled, and a freshly built `Binding(get:set:)` never
  /// compares equal to the previous one. Building it inside the scene body therefore marked
  /// the scene as changed on every update and kept the app graph (main menu, status item,
  /// desktop window) rebuilding on every run loop pass — burning a full CPU core while idle.
  private(set) lazy var statusBarItemEnabledBinding = Binding<Bool>(
    get: { [weak self] in
      self?.statusBarItemEnabled ?? false
    },
    set: { [weak self] newValue in
      // MenuBarExtra writes the insertion state back on every scene update;
      // republishing an unchanged value would retrigger the update in an endless loop
      guard let self, statusBarItemEnabled != newValue else {
        return
      }
      // the write arrives while the graph is updating, so defer it to the next run loop pass
      DispatchQueue.main.async {
        if self.statusBarItemEnabled != newValue {
          self.statusBarItemEnabled = newValue
        }
      }
    }
  )
#endif

  static func forPreview() -> Model {
    let model = Model()
    model.reminders = Reminder.sampleData
    return model
  }
}
