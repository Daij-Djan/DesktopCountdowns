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
    String(format: NSLocalizedString("%d Reminders", comment: "statusbar icon with number of open reminders"), reminders.count)
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
      Self.addRemindersToMenu(reminders, menu)
    }
  }
  
  var reminders: [Reminder] = [] {
    didSet {
      statusBarItem?.button?.title = title
      Self.addRemindersToMenu(reminders, menu)
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
        Self.addRemindersToMenu(reminders, menu)
        
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
}

extension StatusBarItemController {
  private static func addRemindersToMenu(_ reminders: [Reminder], _ menu: NSMenu?) {
    let openRemindersAppAction = #selector(AppDelegate.openRemindersApp(_:))
    
    // gather dynamic reminder items
    let reminderItems = reminders.map { reminder in
      return NSMenuItem(title: menuItemTitleReminder(reminder), action: openRemindersAppAction, keyEquivalent: "")
    }
    
    // assemble new menu by
    // 1. adding old menu items back
    // 2. adding dynamic items and a sentinal action
    var allItems = [NSMenuItem]()
    if let menuItems = menu?.items {
      for menuItem in menuItems {
        if menuItem.isSeparatorItem {
          break
        }
        allItems.append(menuItem)
      }
    }
    allItems.append(NSMenuItem.separator())
    allItems.append(NSMenuItem(title: menuItemTitleForRemindersGroup(), action: nil, keyEquivalent: ""))
    if !reminderItems.isEmpty {
      allItems.append(contentsOf: reminderItems)
      allItems.append(NSMenuItem.separator())
    }
    allItems.append(NSMenuItem(title: menuItemTitleForOpenRemindersApp(), action: openRemindersAppAction, keyEquivalent: "r"))
    menu?.items = allItems
  }
  
  private static func menuItemTitleForRemindersGroup() -> String {
    return NSLocalizedString("REMINDERS", comment: "menu item for reminders group")
  }
  
  private static func menuItemTitleForOpenRemindersApp() -> String {
    return NSLocalizedString("Manage...", comment: "menu item for opening reminders app")
  }
  
  private static func menuItemTitleReminder(_ reminder: Reminder) -> String {
    let title: String
    if let dueDate = reminder.dueDate {
      title = String(format: NSLocalizedString("%@ (%d)...", comment: "menu item for reminder with duedate"), reminder.title, dueDate.daysBetween(Date()))
    } else {
      title = String(format: NSLocalizedString("%@...", comment: "menu item for reminder without duedate"), reminder.title)
    }
    return title
  }
}
