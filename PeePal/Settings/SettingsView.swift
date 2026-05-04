//
//  SettingsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/20/26.
//

import SwiftUI

enum Appearance: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var systemColorScheme: ColorScheme?
    
    @AppStorage(Setting.colorScheme.rawValue) private var appearance: Appearance = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearance) {
                        ForEach(Appearance.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolBarDismissButton()
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .preferredColorScheme(appearance == .system ? systemColorScheme : appearance.colorScheme)
            .onAppear {
                systemColorScheme = colorScheme
            }
        }
    }
}

#Preview {
    SettingsView()
}
