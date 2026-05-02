//
//  CountdownsWidgetView.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.05.26.
//

import SwiftUI
import WidgetKit

// swiftlint:disable no_magic_numbers
struct CountdownsWidgetItem: View {
  let reminder: Reminder

  var body: some View {
    HStack(spacing: 8) {
      Text("\(reminder.countDownDays)")
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(colorForPriority(reminder.priority))
        .frame(minWidth: 36)

      VStack(alignment: .leading, spacing: 2) {
        Text(reminder.title)
          .font(.system(size: 13, weight: .semibold))
          .lineLimit(1)
        if let dueDate = reminder.dueDate {
          Text(dueDate, style: .date)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
    }
  }

  private func colorForPriority(_ priority: Int) -> Color {
    switch priority {
    case 9...:
      return .green
    case 5..<9:
      return .yellow
    case 1..<5:
      return .red
    default:
      return .gray
    }
  }
}

// swiftlint:enable no_magic_numbers
