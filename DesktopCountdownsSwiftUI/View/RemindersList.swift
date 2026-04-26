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
    VStack {
      List(model.reminders, id: \.self) { reminder in
        RemindersListItem(reminder: reminder, viewOptions: model.viewOptions)
      }
    }
    .padding()
#if !os(macOS)
// swiftlint:disable:next indentation_width
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

#Preview {
  RemindersList(model: Model.forPreview())
}
