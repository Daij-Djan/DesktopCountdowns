//
//  CountdownsWidget.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 01.05.26.
//

import SwiftUI
import WidgetKit

@main
struct CountdownsWidget: Widget {
  let kind = "CountdownsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CountdownsTimelineProvider()) { entry in
      CountdownsWidgetView(entry: entry)
        .widgetURL(URL(string: "desktopcountdowns://open-reminders"))
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Countdown Reminders")
    .description("See your upcoming reminders with countdown days.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
