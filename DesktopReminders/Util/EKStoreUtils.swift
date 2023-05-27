//
//  EKStore+AsyncFetch.swift
//  day-in-day-out
//
//  Created by Dominik Pich on 24.05.23.
//

import EventKit
import Foundation

extension EKEventStore {

    func reminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: ReminderError.failedReadingReminders)
                }
            }
        }
    }
}
