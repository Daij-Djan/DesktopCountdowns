//
//  ReminderCell.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 24.05.23.
//

import AppKit

class ReminderCell: NSCollectionViewItem {
  fileprivate struct Defaults {
    static let cornerRadius = 10.0
    static let borderColor = NSColor.darkGray
    static let borderWidth = 0.0
  }
  
  @IBOutlet private var daysCounterLabel: NSTextField!
  @IBOutlet private var customSeparator: NSView!
  @IBOutlet private var titleLabel: NSTextField!
  @IBOutlet private var dueDateLabel: NSTextField!
  
  override func viewDidLoad() {
    view.wantsLayer = true
    view.layer?.cornerRadius = Defaults.cornerRadius
    view.layer?.borderColor = Defaults.borderColor.cgColor
    view.layer?.borderWidth = Defaults.borderWidth
    
    customSeparator.wantsLayer = true
    customSeparator.layer?.backgroundColor = daysCounterLabel.textColor?.cgColor
  }
  
  func update(reminder: Reminder, viewOptions: ViewOptions) {
    titleLabel.stringValue = reminder.title
    dueDateLabel.isHidden = reminder.dueDate == nil
      
    var backgroundColor = ReminderCell.backgroundColorForPriority(reminder.priority, viewOptions: viewOptions)
    var opacity = viewOptions.opacity;
    
    if let dueDate = reminder.dueDate {
      let daysBetween = dueDate.daysBetween(Date())
      daysCounterLabel.stringValue = "\(daysBetween)"
        dueDateLabel.stringValue = dueDate.stringForCurrentLocale(includingTime: reminder.dueDateHasTime)

      if viewOptions.darkenColorsByDueDate {
        backgroundColor = ReminderCell.adjustBackgroundColorForDueDateDaysBetween(backgroundColor, daysBetween)
        opacity = ReminderCell.adjustOpacityForDueDateDaysBetween(opacity, daysBetween)
      }
    }
    else {
      daysCounterLabel.stringValue = "-"
    }

    view.layer?.backgroundColor = backgroundColor.cgColor
    view.layer?.opacity = opacity
  }
  
  private static func backgroundColorForPriority(_ priority : Int, viewOptions: ViewOptions) -> NSColor {
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
  
  private static func adjustBackgroundColorForDueDateDaysBetween(_ backgroundColor : NSColor, _ daysBetween : Int) -> NSColor {
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

  private static func adjustOpacityForDueDateDaysBetween(_ opacity : Float, _ daysBetween : Int) -> Float {
    switch daysBetween {
    case 16...:
      return opacity * 20/100.0
    case 8..<16:
      return opacity * 40/100.0
    case 4..<8:
      return opacity * 60/100.0
    case 2..<4:
      return opacity * 80/100.0
    default:
      return opacity
    }
  }
}

extension ReminderCell {
  static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ReminderCell")
}
