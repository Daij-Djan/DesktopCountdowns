//
//  ScopedAccess.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.05.26.
//

#if canImport(AppKit)
import AppKit

/// Manages access to the Reminders group-container folder via a user-granted
/// security-scoped bookmark. Call startAccessingIfNeeded() on launch and
/// requestAccessOrResume(completion:) when the user first enables the feature.
final class ScopedAccess {
  static let accessGrantedNotification = Notification.Name("ScopedAccessGranted")
  private let bookmarkKey: String
  private let containerURL: URL
  private var scopedURL: URL?

  var isAccessing: Bool { scopedURL != nil }

  init(bookmarkKey: String, containerURL: URL) {
    self.bookmarkKey = bookmarkKey
    self.containerURL = containerURL
  }

  /// Restores access from a previously stored bookmark. Call once on launch.
  func startAccessingIfNeeded() {
    guard !isAccessing, let data = UserDefaults.standard.data(forKey: bookmarkKey) else {
      return }
    resolveAndStart(data)
  }

  /// If a bookmark is already stored, resumes access immediately and calls
  /// completion(true). Otherwise shows an NSOpenPanel so the user can grant
  /// access to the Reminders folder.
  func requestAccessOrResume(completion: @escaping @MainActor (Bool) -> Void) {
    if let data = UserDefaults.standard.data(forKey: bookmarkKey) {
      if !isAccessing { resolveAndStart(data) }
      let result = isAccessing
      Task { @MainActor in completion(result) }
      return
    }
    showPanel(completion: completion)
  }

  /// Stops accessing the security-scoped resource and removes the stored bookmark.
  func stopAccessing() {
    scopedURL?.stopAccessingSecurityScopedResource()
    scopedURL = nil
    UserDefaults.standard.removeObject(forKey: bookmarkKey)
  }

  private func showPanel(completion: @escaping @MainActor (Bool) -> Void) {
    let panel = NSOpenPanel()
    panel.directoryURL = containerURL
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = false
    panel.allowsMultipleSelection = false
    panel.prompt = "Grant Access"
    panel.title = "Allow Access to Reminder Images"
    panel.message = "Click \"Grant Access\" to let Desktop Countdowns read attachment images stored in the Reminders folder."

    panel.begin { [weak self] response in
      guard response == .OK, let url = panel.url else {
        Task { @MainActor in completion(false) }
        return
      }
      do {
        let bookmark = try url.bookmarkData(
          options: .withSecurityScope,
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        )
        UserDefaults.standard.set(bookmark, forKey: self?.bookmarkKey ?? "")
        self?.resolveAndStart(bookmark, postGrantedNotification: true)
        let granted = self?.isAccessing ?? false
        Task { @MainActor in completion(granted) }
      } catch {
        Task { @MainActor in completion(false) }
      }
    }
  }

  private func resolveAndStart(_ bookmark: Data, postGrantedNotification: Bool = false) {
    do {
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: bookmark,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      if url.startAccessingSecurityScopedResource() {
        scopedURL = url
        if postGrantedNotification {
          DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.accessGrantedNotification, object: nil)
          }
        }
      }
      if isStale, let fresh = try? url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      ) {
        UserDefaults.standard.set(fresh, forKey: bookmarkKey)
      }
    } catch {
      print(error)
    }
  }
}
#endif
