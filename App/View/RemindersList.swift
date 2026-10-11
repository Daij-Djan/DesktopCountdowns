//
//  RemindersListItem.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

import SwiftUI

struct RemindersList: View {
  @ObservedObject var model: Model
#if !os(macOS)
  @State private var showingPreferences = false
#endif

  var body: some View {
#if os(macOS)
// swiftlint:disable:next indentation_width
    remindersGrid
#else
// swiftlint:disable:next indentation_width
    VStack {
      List(model.reminders, id: \.self) { reminder in
        RemindersListItem(reminder: reminder, viewOptions: model.viewOptions, imageReloadToken: model.imageReloadToken)
      }
    }
    .padding()
    .navigationTitle("Reminders")
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Button {
          showingPreferences = true
        } label: {
          Image(systemName: "gear").accessibilityLabel(Text("Preferences"))
        }
      }
    }
    .sheet(isPresented: $showingPreferences) {
      NavigationStack {
        PreferencesView()
          .navigationTitle("Preferences")
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button("Done") {
                showingPreferences = false
              }
            }
          }
      }
    }
#endif
  }
}

#if os(macOS)
let kGridSpacing = 4.0

extension RemindersList {
  private struct LayoutSnapshot: Equatable {
    let size: CGSize
    let count: Int
  }

  @ViewBuilder private var remindersGrid: some View {
    let cellWidth = model.viewOptions.cellSize.width
    let cellHeight = model.viewOptions.cellSize.height
    Group {
      switch model.viewOptions.direction {
      case .flowHorizontally:
        ScrollView(.vertical) {
          LazyVGrid(
            columns: [GridItem(.adaptive(minimum: cellWidth), spacing: kGridSpacing)],
            spacing: kGridSpacing
          ) {
            ForEach(model.reminders, id: \.self) { reminder in
              RemindersListItem(reminder: reminder, viewOptions: model.viewOptions, imageReloadToken: model.imageReloadToken)
                .frame(width: cellWidth, height: cellHeight)
            }
          }
        }
        .scrollIndicators(.hidden)
      case .flowVertically:
        ScrollView(.horizontal) {
          LazyHGrid(
            rows: [GridItem(.adaptive(minimum: cellHeight), spacing: kGridSpacing)],
            spacing: kGridSpacing
          ) {
            ForEach(model.reminders, id: \.self) { reminder in
              RemindersListItem(reminder: reminder, viewOptions: model.viewOptions, imageReloadToken: model.imageReloadToken)
                .frame(width: cellWidth, height: cellHeight)
            }
          }
        }
        .scrollIndicators(.hidden)
      }
    }
    .debugLog("body: \(model.reminders.count) reminders, direction=\(model.viewOptions.direction), cell=\(cellWidth)x\(cellHeight)")
    // includes the count so the layout is logged again once reminders arrive, not only on resize
    .onGeometryChange(for: LayoutSnapshot.self) { proxy in
      LayoutSnapshot(size: proxy.size, count: model.reminders.count)
    } action: { snapshot in
      Self.logLayout(size: snapshot.size, cellSize: model.viewOptions.cellSize, direction: model.viewOptions.direction, count: snapshot.count)
    }
  }

  private static func logLayout(size: CGSize, cellSize: CGSize, direction: ViewOptions.FlowDirection, count: Int) {
    // mirrors the adaptive grid: as many cells as fit, separated by kGridSpacing
    let fitting = { (available: CGFloat, cell: CGFloat) in max(1, Int((available + kGridSpacing) / (cell + kGridSpacing))) }
    switch direction {
    case .flowHorizontally:
      let columns = fitting(size.width, cellSize.width)
      DebugLog.log("layout: \(size.width)x\(size.height), \(columns) columns, \((count + columns - 1) / columns) rows needed")
    case .flowVertically:
      let rows = fitting(size.height, cellSize.height)
      DebugLog.log("layout: \(size.width)x\(size.height), \(rows) rows, \((count + rows - 1) / rows) columns needed")
    }
  }
}
#endif

#Preview {
  RemindersList(model: Model.forPreview())
}
