//
//  SettingsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var settingsViewModel: SettingsViewModel?
    @State private var systemColorScheme: ColorScheme?
    @State private var showDeletionAlert: Bool = false
    
    @AppSetting(.colorScheme) private var appearance: Appearance
    @AppSetting(.directionsProvider) private var directionsProvider: DirectionsProvider
    @AppSetting(.liquidGlassDisabled) private var isLiquidGlassDisabled: Bool
    @AppSetting(.mapMode) private var mapMode: MapMode
    @AppSetting(.offlineMode) private var isOfflineModeEnabled: Bool
    
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
                    Picker("Map style", selection: $mapMode) {
                        ForEach(MapMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Directions provider", selection: $directionsProvider) {
                        ForEach(DirectionsProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    VStack(alignment: .leading) {
                        Toggle("Offline mode", isOn: $isOfflineModeEnabled)
                        Text("Disables automatic fetch")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Link(destination: URL(string: "https://www.refugerestrooms.org/restrooms/new")!) {
                            HStack {
                                Text("Add a restroom")
                                Spacer()
                                Image(systemName: "arrow.up.forward.app")
                            }
                        }
                        .foregroundStyle(.blue)
                        
                        Text("Opens Refuge Restrooms in your browser")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Delete all local storage", role: .destructive) {
                        showDeletionAlert = true
                    }
                    .alert(
                        "This will delete all locally-stored restrooms. The experience will be slower until the ones you care about re-download. Are you sure?",
                        isPresented: $showDeletionAlert
                    ) {
                        Button("Yes, delete", role: .destructive) {
                            Task {
                                await settingsViewModel?.deleteAllLocalRestrooms()
                            }
                        }
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
            .preferredColorScheme(appearance == .system ? systemColorScheme : appearance.scheme)
            .alert(
                settingsViewModel?.error ?? "There was an error completing your task. Please try again.",
                isPresented: .init(get: {
                    settingsViewModel?.showErrorAlert ?? false
                }, set: { newValue in
                    settingsViewModel?.showErrorAlert = newValue
                }),
                actions: {}
            )
            .onAppear {
                systemColorScheme = colorScheme
                settingsViewModel = SettingsViewModel(modelContext: modelContext)
            }
        }
        .transition(.identity) // No going crazy when we toggle Liquid Glass
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .modelContainer(DataController.previewContainer)
}
#endif
