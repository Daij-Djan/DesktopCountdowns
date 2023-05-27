//
//  DesktopWindowController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa

struct DesktopWindowController {
  private var window : NSWindow?;

  var currentRemindersViewController : RemindersViewController? {
    return window?.contentViewController as? RemindersViewController
  }

  // MARK: public
  
  var reminders: [Reminder] = [] {
    didSet {
      currentRemindersViewController?.reminders = reminders
    }
  }

  var viewOptions: ViewOptions = ViewOptions.default {
    didSet {
      currentRemindersViewController?.viewOptions = viewOptions
    }
  }

  var enabled: Bool = false {
    didSet {
      if enabled {
        let rect = NSScreen.main!.visibleFrame.insetBy(dx: viewOptions.screenFrameInset, dy: viewOptions.screenFrameInset)
        
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

        let vc = RemindersViewController()
        vc.reminders = reminders
        vc.viewOptions = viewOptions
        vc.view.frame = window.contentLayoutRect
        window.contentViewController = vc
        
        self.window = window
        window.orderFrontRegardless()
      } else {
        window?.orderOut(nil)
        window = nil
      }
    }
  }
}
