//
//  ReminderCell.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 24.05.23.
//

import AppKit

class ReminderCell: NSCollectionViewItem {
  @IBOutlet private var daysCounterLabel: NSTextField!
  @IBOutlet private var customSeparator: NSView!
  @IBOutlet private var titleLabel: NSTextField!
  @IBOutlet private var dueDateLabel: NSTextField!
  
  // swiftlint:disable no_magic_numbers
  
  private static func backgroundColorForPriority(_ priority: Int, viewOptions: ViewOptions) -> NSColor {
    switch priority {
    case 9...:
      return viewOptions.lowpriColor
      
    case 5..<9:
      return viewOptions.midpriColor
      
    case 1..<5:
      return viewOptions.highpriColor
      
    default:
      return viewOptions.defaultColor
    }
  }
  
  private static func adjustBackgroundColorForDueDateDaysBetween(_ backgroundColor: NSColor, _ daysBetween: Int) -> NSColor {
    switch daysBetween {
    case 16...:
      return backgroundColor.darker(by: 50)
      
    case 8..<16:
      return backgroundColor.darker(by: 30)
      
    case 4..<8:
      return backgroundColor.darker(by: 20)
      
    case 2..<4:
      return backgroundColor.darker(by: 15)
      
    default:
      return backgroundColor
    }
  }
  
  private static func adjustOpacityForDueDateDaysBetween(_ opacity: Float, _ daysBetween: Int) -> Float {
    switch daysBetween {
    case 16...:
      return opacity * 20 / 100.0
      
    case 8..<16:
      return opacity * 40 / 100.0
      
    case 4..<8:
      return opacity * 60 / 100.0
      
    case 2..<4:
      return opacity * 80 / 100.0
      
    default:
      return opacity
    }
  }
  // swiftlint:enable no_magic_numbers
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.wantsLayer = true
    customSeparator.wantsLayer = true
    customSeparator.layer?.backgroundColor = daysCounterLabel.textColor?.cgColor
  }
  
  func update(reminder: Reminder, viewOptions: ViewOptions) {
    titleLabel.stringValue = reminder.title
    dueDateLabel.isHidden = reminder.dueDate == nil
    
    var backgroundColor = Self.backgroundColorForPriority(reminder.priority, viewOptions: viewOptions)
    var opacity = viewOptions.opacity
    
    if let dueDate = reminder.dueDate {
      let daysBetween = dueDate.daysBetween(Date())
      daysCounterLabel.stringValue = "\(daysBetween)"
      dueDateLabel.stringValue = dueDate.stringForCurrentLocale(includingTime: reminder.dueDateHasTime)
      
      if viewOptions.darkenColorsByDueDate {
        backgroundColor = Self.adjustBackgroundColorForDueDateDaysBetween(backgroundColor, daysBetween)
        opacity = Self.adjustOpacityForDueDateDaysBetween(opacity, daysBetween)
      }
    } else {
      daysCounterLabel.stringValue = "-"
    }
    
    view.layer?.cornerRadius = viewOptions.cellCornerRadius
    view.layer?.backgroundColor = backgroundColor.cgColor
    view.layer?.opacity = opacity
  }  
}

extension ReminderCell {
  static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ReminderCell")
}
