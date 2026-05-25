//
//  ScopedAccess+Attachments.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.26.
//

#if canImport(AppKit)
import AppKit

extension ScopedAccess {
  static let shared = ScopedAccess(bookmarkKey: "remindersAttachmentsBookmark", containerURL: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Group Containers/group.com.apple.reminders"))
}
#endif
