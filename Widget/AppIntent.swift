//
//  AppIntent.swift
//  Widget
//
//  Created by Dominik Pich on 5/1/26.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource { "Configuration" }
  static var description: IntentDescription { "This is an example widget." }

  // An example configurable parameter.
  @Parameter(title: "Favorite Emoji", default: "😃")
  var favoriteEmoji: String
}
