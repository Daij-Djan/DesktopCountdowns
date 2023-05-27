//
//  DesktopWindowController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa

struct DesktopWindowController {
  private var window: NSWindow?

  private var currentRemindersViewController: RemindersViewController? {
    window?.contentViewController as? RemindersViewController
  }

  var reminders: [Reminder] = [] {
    didSet {
      currentRemindersViewController?.reminders = reminders
    }
  }

  var viewOptions = ViewOptions.default {
    didSet {
      currentRemindersViewController?.viewOptions = viewOptions
    }
  }

  var enabled = false {
    didSet {
      if enabled {
        let rect = NSScreen.main?.visibleFrame.insetBy(dx: viewOptions.screenFrameInset, dy: viewOptions.screenFrameInset) ?? CGRect.zero

        let window = NSWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        window.ignoresMouseEvents = true
        window.backgroundColor = .clear
        window.collectionBehavior = [.stationary, .canJoinAllSpaces]
        window.level = .init(rawValue: NSWindow.Level.normal.rawValue - 1)
        #if DEBUG
        if DebuggerUtils.isDebuggerAttached() {
          print("keep window normal for easier debugging")
          window.level = .normal
        }
        #endif

        let listViewController = RemindersViewController()
        listViewController.reminders = reminders
        listViewController.viewOptions = viewOptions
        listViewController.view.frame = window.contentLayoutRect
        window.contentViewController = listViewController

        self.window = window
        window.orderFrontRegardless()
      } else {
        window?.orderOut(nil)
        window = nil
      }
    }
  }
}
