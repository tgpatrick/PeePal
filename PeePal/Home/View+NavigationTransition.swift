//
//  View+NavigationTransition.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/19/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func transitionSourceIfAvailable(id: AnyHashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func zoomTransitionIfAvailable(sourceID: AnyHashable, in namespace: Namespace.ID, enabled: Bool) -> some View {
        if #available(iOS 18.0, *), enabled {
            self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}

extension UIDevice {
    static var isIpad: Bool {
        current.userInterfaceIdiom == .pad
    }
}
