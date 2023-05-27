//
//  StatusBarItemController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import Cocoa


struct StatusBarItemController {
  fileprivate struct Defaults {
    static let statusBarIconSize = NSSize(width: 22, height: 22)
  }
  
  private var statusBarItem: NSStatusItem?
    
  private var title: String {
    return String(format: NSLocalizedString("%d Reminders", comment: "number of open reminders"), reminders.count)
  }
  
  private var image: NSImage? {
    let image = NSImage(named: "StatusBarIcon")
    image?.size = Defaults.statusBarIconSize
    return image
  }
  
  //MARK: public
  
  var menu: NSMenu? {
    didSet {
      statusBarItem?.menu = menu
    }
  }
  
  var reminders: [Reminder] = [] {
    didSet {
      statusBarItem?.button?.title = self.title
      //TODO update menu
    }
  }

  var enabled: Bool = false {
    didSet {
      if enabled {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu

        let button = statusBarItem.button!
        button.title = title
        button.font = NSFont.systemFont(ofSize: 13)
        button.image = image
        button.imagePosition = .imageLeading
        button.imageHugsTitle = true
        
        self.statusBarItem = statusBarItem
      } else {
        statusBarItem = nil
      }
    }
  }
}
