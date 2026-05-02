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
        RemindersListItem(reminder: reminder, viewOptions: model.viewOptions)
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
  @ViewBuilder private var remindersGrid: some View {
    let cellWidth = model.viewOptions.cellSize.width
    let cellHeight = model.viewOptions.cellSize.height

    switch model.viewOptions.direction {
    case .flowHorizontally:
      ScrollView(.vertical) {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: cellWidth), spacing: kGridSpacing)],
          spacing: kGridSpacing
        ) {
          ForEach(model.reminders, id: \.self) { reminder in
            RemindersListItem(reminder: reminder, viewOptions: model.viewOptions)
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
            RemindersListItem(reminder: reminder, viewOptions: model.viewOptions)
              .frame(width: cellWidth, height: cellHeight)
          }
        }
      }
      .scrollIndicators(.hidden)
    }
  }
}
#endif

#Preview {
  RemindersList(model: Model.forPreview())
}
