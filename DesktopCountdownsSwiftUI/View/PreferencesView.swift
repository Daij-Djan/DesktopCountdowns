//
//  PreferencesView.swift
//  DesktopCountdowns
//
//  Created by Dominik Pich on 25.04.26.
//

import SwiftUI

// swiftlint:disable no_magic_numbers

struct PreferencesView: View {
  @AppStorage(UserDefaults.Key.onlyWithDueDate) private var onlyWithDueDate = FetchOptions.default.onlyWithDueDate
  @AppStorage(UserDefaults.Key.orderByDueDate) private var orderByDueDate = FetchOptions.default.orderByDueDate

  @AppStorage(UserDefaults.Key.opacity) private var opacity: Double = 90
  @AppStorage(UserDefaults.Key.direction) private var direction = ViewOptions.default.direction.rawValue
  @AppStorage(UserDefaults.Key.darkenColorByDueDate) private var darkenColorByDueDate = ViewOptions.default.darkenColorByDueDate
  @AppStorage(UserDefaults.Key.fadeColorByDueDate) private var fadeColorByDueDate = ViewOptions.default.fadeColorByDueDate


#if canImport(AppKit)
  @AppStorage(UserDefaults.Key.dockIcon) private var dockIcon = AppOptions.default.dockIcon
  @AppStorage(UserDefaults.Key.statusBarItem) private var statusBarItem = AppOptions.default.statusBarItem
  @AppStorage(UserDefaults.Key.openAtLogin) private var openAtLogin = AppOptions.default.openAtLogin
#endif

  var body: some View {
    Form {
      Section {
        Toggle("Show Only Reminders With Due Date", isOn: $onlyWithDueDate)
        Toggle("Show Reminders Ordered By Due Date", isOn: $orderByDueDate)
      }

      Section {
        VStack(alignment: .leading) {
          Text("Opacity Of Reminders:")
          Slider(value: $opacity, in: 0...100)
        }

        Picker("Layout Flow Direction:", selection: $direction) {
          Text("Horizontal").tag(ViewOptions.FlowDirection.flowHorizontally.rawValue)
          Text("Vertical").tag(ViewOptions.FlowDirection.flowVertically.rawValue)
        }
        .pickerStyle(.segmented)
      }

#if !os(watchOS)
      Section("Reminder Color By Priority") {
        HStack {
          colorPickerItem("LowPri", key: UserDefaults.Key.lowpriColor, default: ViewOptions.default.lowpriColor)
          colorPickerItem("MidPri", key: UserDefaults.Key.midpriColor, default: ViewOptions.default.midpriColor)
          colorPickerItem("HighPri", key: UserDefaults.Key.highpriColor, default: ViewOptions.default.highpriColor)
          colorPickerItem("Default", key: UserDefaults.Key.defaultColor, default: ViewOptions.default.defaultColor)
        }
      }
#endif

      Section {
        Toggle("Darken reminders' background color the later they are due", isOn: $darkenColorByDueDate)
        Toggle("Reduce reminders' opacity the later they are due", isOn: $fadeColorByDueDate)
      }

#if canImport(AppKit)
      Section {
        Toggle("App Should Show Dock Icon", isOn: $dockIcon)
        Toggle("App Should Show Menubar Icon", isOn: Binding(
          get: { !dockIcon || statusBarItem },
          set: { statusBarItem = $0 }
        ))
        .disabled(!dockIcon)
        Toggle("App Should Open At Login", isOn: $openAtLogin)
      }
#endif

      Section {
        HStack {
          Spacer()
          VStack {
            Text("Copyright 2025 Dominik Pich")
              .font(.footnote)
            if let url = URL(string: "https://www.pich.info") {
              Link("https://www.pich.info", destination: url)
                .font(.footnote)
            }
          }
          Spacer()
        }
      }
    }
    .formStyle(.grouped)
  }

#if !os(watchOS)
  private func colorPickerItem(_ label: String, key: String, default defaultColor: Color) -> some View {
    VStack {
      ColorPicker("", selection: Binding(
        get: { UserDefaults.standard.color(forKey: key) ?? defaultColor },
        set: { UserDefaults.standard.set($0.rawValue, forKey: key) }
      ), supportsOpacity: false)
        .labelsHidden()
      Text(label)
        .font(.caption)
    }
    .frame(maxWidth: .infinity)
  }
#endif
}

// swiftlint:enable no_magic_numbers

#Preview {
  PreferencesView()
}
