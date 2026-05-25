//
//  CountdownsWidgetItem.swift
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
        HStack(spacing: 3) {
          Text(reminder.title)
            .font(.system(size: 13, weight: .semibold))
            .lineLimit(1)
          if reminder.isFlagged {
            Image(systemName: "flag.fill")
              .font(.system(size: 9))
              .foregroundStyle(.orange)
              .accessibilityLabel("Flagged")
          }
        }
        if let dueDate = reminder.dueDate {
          Text(dueDate, style: .date)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        if !reminder.tags.isEmpty {
          HStack(spacing: 3) {
            ForEach(reminder.tags, id: \.self) { tag in
              Text("#\(tag)")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      Spacer()
      if let url = reminder.attachmentImageURLs.first {
        AsyncImage(url: url) { phase in
          if let image = phase.image {
            image
              .resizable()
              .scaledToFill()
          } else {
            Color.clear
          }
        }
        .frame(width: 36, height: 36)
        .clipShape(RoundedRectangle(cornerRadius: 4))
      }
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
