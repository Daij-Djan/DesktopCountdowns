//
//  ReminderCell.swift
//  DesktopCountdowns
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
    guard daysBetween >= 0 else {
      return backgroundColor
    }
      
    let maxDarkening = Double(50)
    let daysForCalculation = Double(daysBetween)
    let newDarkening = min(daysForCalculation / 1.6, maxDarkening)

    return backgroundColor.darker(by: newDarkening)
  }
  
  private static func adjustOpacityForDueDateDaysBetween(_ opacity: Float, _ daysBetween: Int) -> Float {
    guard daysBetween >= 0 else {
      return opacity
    }
      
    let maxOpacity = Double(opacity * 100)
    let minOpacity = Double(maxOpacity / 100 * 20)
    let daysForCalculation = Double(daysBetween)
    let newOpacity = max(min(maxOpacity - pow(daysForCalculation, 1.1), maxOpacity), minOpacity)

    return Float(newOpacity / 100)
  }
  // swiftlint:enable no_magic_numbers
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.wantsLayer = true
    customSeparator.wantsLayer = true
    customSeparator.layer?.backgroundColor = daysCounterLabel.textColor?.cgColor
  }
  
  func update(reminder: Reminder, viewOptions: ViewOptions) {
    var opacity = viewOptions.opacity
    var backgroundColor = Self.backgroundColorForPriority(reminder.priority, viewOptions: viewOptions)
    
    if let dueDate = reminder.dueDate {
      let daysBetween = dueDate.daysBetween(Date())
      daysCounterLabel.stringValue = "\(daysBetween)"
      dueDateLabel.stringValue = dueDate.stringForCurrentLocale(includingTime: reminder.dueDateHasTime)
      
      if viewOptions.darkenColorByDueDate {
        backgroundColor = Self.adjustBackgroundColorForDueDateDaysBetween(backgroundColor, daysBetween)
      }

      if viewOptions.fadeColorByDueDate {
        opacity = Self.adjustOpacityForDueDateDaysBetween(opacity, daysBetween)
      }
    } else {
      daysCounterLabel.stringValue = "-"
    }
    
    titleLabel.stringValue = reminder.title
    dueDateLabel.isHidden = reminder.dueDate == nil
    
    view.layer?.cornerRadius = viewOptions.cellCornerRadius
    view.layer?.backgroundColor = backgroundColor.cgColor
    view.layer?.opacity = opacity
  }  
}

extension ReminderCell {
  static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ReminderCell")
}
