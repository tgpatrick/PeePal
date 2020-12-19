//
//  TutorialViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import SwiftUI

class TutorialViewModel: ObservableObject {
    @ObservedObject var sm: SharedModel
    
    init(sharedModel: SharedModel) {
        self.sm = sharedModel
    }
    
    func done() {
        UserDefaults.standard.setValue(true, forKey: "seenTutorial")
        sm.showTutorial = false
        sm.reCenter(group: nil)
    }
}
