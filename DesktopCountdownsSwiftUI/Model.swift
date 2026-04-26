//
//  Options.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.23.
//

import Foundation

final class Model: ObservableObject {
  @Published var reminders: [Reminder] = []
  @Published var viewOptions: ViewOptions = .default
#if canImport(AppKit)
  @Published var statusBarItemEnabled = true
#endif

  static func forPreview() -> Model {
    let model = Model()
    model.reminders = Reminder.sampleData
    return model
  }
}
