//
//  RemindersPrivateFrameworkBackingStore.swift
//  DesktopCountdowns
//
//  Private ReminderKit field extraction used by EventKitBackingStore.
//
//  Verified call chain (macOS 26.5):
//    EKReminder
//      ._persistentObject  → EKFrozenReminderReminder
//        ._remObject        → REMReminder  (ReminderKit.framework)
//          .hashtagContext  → REMReminderHashtagContext
//            .hashtags      → NSSet<REMHashtag>
//              .name        → NSString
//          .flaggedContext  → REMReminderFlaggedContext
//            .flagged       → BOOL
//          .attachmentContext → REMReminderAttachmentContext
//            .attachmentsOfClass:(REMImageAttachment) → NSArray<REMImageAttachment>
//              .fileURL     → URL (local group-container path)

#if canImport(EventKit)
import EventKit

struct REMPrivateFields {
  var tags: [String] = []
  var isFlagged = false
  var attachmentImageURLs: [URL] = []
}

extension EKReminder {
  /// Single traversal of the private object graph to read all ReminderKit-only fields.
  var remPrivateFields: REMPrivateFields {
    var result = REMPrivateFields()
    guard
      let frozen = value(forKey: "_persistentObject") as? AnyObject,
      let rem    = frozen.value(forKey: "_remObject")  as? AnyObject
    else {
      return result
    }

    // Tags: hashtagContext → hashtags (NSSet<REMHashtag>) → name
    if
      let ctx = rem.value(forKey: "hashtagContext") as? AnyObject,
      let tagSet = ctx.value(forKey: "hashtags") as? Set<NSObject> {
      result.tags = tagSet.compactMap { $0.value(forKey: "name") as? String }
    }

    // Flagged: flaggedContext → flagged (BOOL — use value(forKey:) to box as NSNumber)
    if let ctx = rem.value(forKey: "flaggedContext") as? AnyObject {
      result.isFlagged = ctx.value(forKey: "flagged") as? Bool ?? false
    }

    // Image attachment: attachmentContext → attachmentsOfClass:(REMImageAttachment) → fileURL
    if let ctx = rem.value(forKey: "attachmentContext") as? AnyObject {
      let ofClassSel = NSSelectorFromString("attachmentsOfClass:")

      if
        let remImageClass = NSClassFromString("REMImageAttachment"),
        ctx.responds(to: NSSelectorFromString("attachmentsOfClass:")),
        let attachments = ctx.perform(ofClassSel, with: remImageClass)?.takeUnretainedValue() as? [AnyObject] {
        let urls = attachments.compactMap { $0.value(forKey: "fileURL") as? URL }
        result.attachmentImageURLs = urls
      }
    }

    return result
  }
}
#endif
