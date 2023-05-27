//
//  StatusBarItemController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa

struct StatusBarItemController {
  private var statusBarItem: NSStatusItem?

  private var title: String {
    String(format: NSLocalizedString("%d Reminders", comment: "number of open reminders"), reminders.count)
  }

  private var image: NSImage? {
    // swiftlint:disable object_literal
    // using #imageLiteral here makes it harder to read
    return NSImage(named: "StatusBarIcon")
    // swiftlint:enable object_literal
  }

  var menu: NSMenu? {
    didSet {
      statusBarItem?.menu = menu
      addRemindersToMenu()
    }
  }

  var reminders: [Reminder] = [] {
    didSet {
      statusBarItem?.button?.title = title
      addRemindersToMenu()
    }
  }

  var viewOptions = ViewOptions.default {
    didSet {
      statusBarItem?.button?.image?.size = viewOptions.statusBarIconSize
      statusBarItem?.button?.font = viewOptions.statusBarFont
    }
  }
  
  var enabled = false {
    didSet {
      if enabled {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        addRemindersToMenu()
        
        if let button = statusBarItem.button {
          button.title = title
          button.font = viewOptions.statusBarFont
          button.image = image
          button.image?.size = viewOptions.statusBarIconSize
          button.imagePosition = .imageLeading
          button.imageHugsTitle = true
        }
        
        self.statusBarItem = statusBarItem
      } else {
        statusBarItem = nil
      }
    }
  }
  
  private func addRemindersToMenu() {
    // TODO
  }
}
