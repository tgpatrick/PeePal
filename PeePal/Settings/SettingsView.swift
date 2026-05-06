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
    @AppStorage(Setting.googleMapsEnabled.rawValue) private var isGoogleMapsEnabled: Bool = false
    @AppStorage(Setting.liquidGlassDisabled.rawValue) private var isLiquidGlassDisabled: Bool = false
    @AppStorage(Setting.offlineMode.rawValue) private var isOfflineModeEnabled: Bool = false
    
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
                
                Section(header: Text("Map")) {
                    VStack(alignment: .leading) {
                        Toggle("Offline mode", isOn: $isOfflineModeEnabled)
                        Text("Disables automatic fetch")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Toggle("Use Google Maps directions", isOn: $isGoogleMapsEnabled)
                    
                    VStack(alignment: .leading) {
                        Link(destination: URL(string: "https://www.refugerestrooms.org/restrooms/new")!) {
                            HStack {
                                Text("Add a restroom")
                                Spacer()
                                Image(systemName: "arrow.up.forward.app")
                            }
                        }
                        .foregroundStyle(.unisex)
                        
                        Text("Opens Refuge Restrooms in your browser")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if #available(iOS 26.0, *) {
                    Section(header: Text("Accessibility")) {
                        VStack(alignment: .leading) {
                            Toggle("Reduce Liquid Glass", isOn: $isLiquidGlassDisabled)
                            Text("Adds solid backgrounds and reduces animations")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
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
        .transition(.identity) // Other
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif
