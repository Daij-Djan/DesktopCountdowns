//
//  DebugLog.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 11.10.26.
//

import Foundation
import os

// MARK: Debug logging that can be switched on/off at runtime, in debug and release builds alike
enum DebugLog {
  /// UserDefaults key of the on/off switch
  static let enabledKey = "debugLogging"

  /// The file all messages are appended to while logging is enabled
  static let fileURL: URL = {
    let logsDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("Logs", isDirectory: true)
    return logsDir.appendingPathComponent("DesktopCountdowns-Debug.log")
  }()

  // swiftlint:disable:next no_magic_numbers
  private static let maxFileSize = 5 * 1_024 * 1_024
  private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DesktopCountdowns", category: "debug")
  private static let queue = DispatchQueue(label: "DesktopCountdowns.DebugLog")
  private static let dateFormatter = ISO8601DateFormatter()

#if DEBUG
  // like AppOptions.debugAlwaysShowsDock: debug builds always log, regardless of the setting
  private static let debugAlwaysLogs = true
#endif

  static var isEnabled: Bool {
#if DEBUG
// swiftlint:disable:next indentation_width
    if debugAlwaysLogs {
      return true
    }
#endif
// swiftlint:disable:next indentation_width
    return UserDefaults.standard.bool(forKey: enabledKey)
  }

  /// Logs `message` to the unified log and the log file — only if logging is enabled.
  /// The message is an autoclosure so it costs nothing while logging is off.
  static func log(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: Int = #line) {
    guard isEnabled else {
      return
    }
    let text = "[\(file):\(line) \(function)] \(message())"
    logger.notice("\(text, privacy: .public)")

    let date = Date()
    queue.async {
      append("\(dateFormatter.string(from: date)) \(text)\n")
    }
  }

  /// Makes sure the log file exists (so it can be opened) and returns its URL
  static func ensureFileExists() -> URL {
    queue.sync {
      createFileIfNeeded()
    }
    return fileURL
  }

  static func clear() {
    queue.async {
      try? FileManager.default.removeItem(at: fileURL)
    }
  }

  // MARK: private, only to be called on queue

  private static func createFileIfNeeded() {
    let fileManager = FileManager.default
    guard !fileManager.fileExists(atPath: fileURL.path) else {
      return
    }
    try? fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    fileManager.createFile(atPath: fileURL.path, contents: nil)
  }

  private static func append(_ line: String) {
    createFileIfNeeded()
    guard let handle = try? FileHandle(forWritingTo: fileURL) else {
      return
    }
    defer { try? handle.close() }

    // start over instead of growing forever
    if let size = try? handle.seekToEnd(), size > maxFileSize {
      try? handle.truncate(atOffset: 0)
    }
    if let data = line.data(using: .utf8) {
      try? handle.write(contentsOf: data)
    }
  }
}
