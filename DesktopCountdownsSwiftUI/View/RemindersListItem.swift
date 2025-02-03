//
//  RemindersListItem.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

import SwiftUI

struct RemindersListItem: View {
  @State var reminder: Reminder
  @State var viewOptions: ViewOptions
  
  var body: some View {
    HStack {
      if reminder.dueDate != nil {
        VStack {
          Text(Self.stringForCountdown(reminder.countDownDays))
            .font(Font.system(.largeTitle))
          Text("DAYS")
        }
        Divider()
      }
      VStack(alignment: .leading) {
        Text(reminder.title)
          .font(Font.system(.headline))
        if let dueDate = reminder.dueDate {
          Text(Self.stringForDueDate(dueDate, reminder.dueDateHasTime))
        }
      }
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .leading
    )
    .padding()
    .background(Self.backgroundColorForReminder(reminder, viewOptions))
    .cornerRadius(Self.opacityForReminder(reminder, viewOptions))
  }
}

#Preview {
  // swiftlint:disable no_magic_numbers
  let model = Model.forPreview()
  RemindersListItem(reminder: model.reminders[3], viewOptions: model.viewOptions).frame(
    maxWidth: model.viewOptions.cellSize.width,
    maxHeight: model.viewOptions.cellSize.height
  )
  // swiftlint:enable no_magic_numbers
}

extension RemindersListItem {
  // swiftlint:disable no_magic_numbers
  private static func opacityForReminder(_ reminder: Reminder, _ viewOptions: ViewOptions) -> CGFloat {
    var opacity = viewOptions.opacity
    if reminder.dueDate != nil, viewOptions.fadeColorByDueDate {
      opacity = Self.adjustOpacityForDueDateCountDownDays(opacity, reminder.countDownDays)
    }
    return opacity
  }
  
  private static func backgroundColorForReminder(_ reminder: Reminder, _ viewOptions: ViewOptions) -> Color {
    var color = Self.backgroundColorForPriority(reminder.priority, viewOptions)
    if reminder.dueDate != nil, viewOptions.darkenColorByDueDate {
      color = Self.adjustBackgroundColorForCountDownDays(color, reminder.countDownDays)
    }
    return color
  }
  
  private static func stringForCountdown(_ countDownDays: Int) -> String {
    return "\(countDownDays)"
  }
  
  private static func stringForDueDate(_ dueDate: Date, _ hasTime: Bool) -> String {
    return dueDate.stringForCurrentLocale(includingTime: hasTime)
  }
}

extension RemindersListItem {
  private static func backgroundColorForPriority(_ priority: Int, _ viewOptions: ViewOptions) -> Color {
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
  
  private static func adjustBackgroundColorForCountDownDays(_ backgroundColor: Color, _ countDownDays: Int) -> Color {
    guard countDownDays >= 0 else {
      return backgroundColor
    }
    
    let maxDarkening = Double(50)
    let daysForCalculation = Double(countDownDays)
    let newDarkening = min(daysForCalculation / 1.6, maxDarkening)
    
    return backgroundColor.darker(by: newDarkening)
  }
  
  private static func adjustOpacityForDueDateCountDownDays(_ opacity: CGFloat, _ countDownDays: Int) -> CGFloat {
    guard countDownDays >= 0 else {
      return opacity
    }
    
    let maxOpacity = Double(opacity * 100)
    let minOpacity = Double(maxOpacity / 100 * 20)
    let daysForCalculation = Double(countDownDays)
    let newOpacity = max(min(maxOpacity - pow(daysForCalculation, 1.1), maxOpacity), minOpacity)
    
    return CGFloat(newOpacity / 100)
  }
  // swiftlint:enable no_magic_numbers
}
