//
//  RemindersListItem.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.02.25.
//

import SwiftUI

struct RemindersList: View {
  @ObservedObject var model: Model
  
  var body: some View {
    VStack {
      List(model.reminders, id: \.self) { reminder in
        RemindersListItem(reminder: reminder, viewOptions: model.viewOptions)
      }
    }
    .padding()
  }
}

#Preview {
  RemindersList(model: Model.forPreview())
}
