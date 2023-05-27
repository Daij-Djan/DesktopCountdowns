//
//  DateUtils
//  DesktopReminders
//
//  Created by Dominik Pich on 6/27/20.
//

import AppKit

extension Date {
  func daysBetween(_ date: Date?) -> Int {
    guard let date else {
      return 0
    }
    
    let calendar = Calendar.current
    let date1 = calendar.startOfDay(for: date)
    let date2 = calendar.startOfDay(for: self)
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    return components.day ?? 0
  }
  
  fileprivate static var localDateFormatter : DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium;
    dateFormatter.locale = NSLocale.current
    return dateFormatter
  }()
  fileprivate static var localDateTimeFormatter : DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium;
    dateFormatter.timeStyle = .medium;
    dateFormatter.locale = NSLocale.current
    return dateFormatter
  }()
  
  func stringForCurrentLocale(includingTime: Bool = true) -> String {
    return (includingTime ? Date.localDateTimeFormatter : Date.localDateFormatter).string(from: self)
  }
}
