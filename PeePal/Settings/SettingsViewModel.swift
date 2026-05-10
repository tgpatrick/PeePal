//
//  SettingsViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {
    private let restroomManager: RestroomManager
    var showErrorAlert: Bool = false
    var error: String?
    
    init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }
    
    func deleteAllLocalRestrooms() async {
        guard await restroomManager.deleteAllLocalRestrooms() else {
            self.error = error 
            showErrorAlert = true
            return
        }
        try? await restroomManager.initializeFromBundleIfNeeded()
    }
}
