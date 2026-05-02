//
//  DesktopWindow.swift
//  DesktopCountdowns
//

#if canImport(AppKit)
import AppKit
import SwiftUI

struct DesktopWindow {
  private var window: NSWindow?
  private let model: Model

  init(model: Model) {
    self.model = model
  }

  mutating func show() {
    if window != nil {
      return
    }

    let inset = model.viewOptions.screenFrameInset
    let rect = NSScreen.main?.visibleFrame.insetBy(dx: inset, dy: inset) ?? .zero

    let window = NSWindow(
      contentRect: rect,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.isOpaque = false
    window.ignoresMouseEvents = true
    window.backgroundColor = .clear
    window.collectionBehavior = [.stationary, .canJoinAllSpaces]
    window.level = .init(rawValue: NSWindow.Level.normal.rawValue - 1)

    #if DEBUG
    if model.viewOptions.debugKeepsWindowMode, DeveloperUtils.isDebuggerAttached() {
      window.level = .normal
    }
    #endif

    let contentView = NSHostingView(
      rootView: RemindersList(model: model)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    )
    window.contentView = contentView

    self.window = window
    window.orderFrontRegardless()
  }

  mutating func hide() {
    window?.orderOut(nil)
    window = nil
  }

  mutating func updateFrame() {
    guard let window else { return }
    let inset = model.viewOptions.screenFrameInset
    let rect = NSScreen.main?.visibleFrame.insetBy(dx: inset, dy: inset) ?? .zero
    window.setFrame(rect, display: true)
  }
}
#endif
