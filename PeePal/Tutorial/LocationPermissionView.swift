//
//  LocationPermissionView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/20/26.
//

import SwiftUI

struct LocationPermissionView: View {
    let locationManager: LocationManager
    
    var body: some View {
        VStack {
            Image(systemName: .locationCircleFillIcon)
                .tutorialImageStyle()
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("Share your location")
                    .tutorialTitleStyle()
                
                Text("PeePal uses your current location to show where you are on the map and help you find nearby restrooms.")
                    .tutorialSubtitleStyle()
                
                Text("We don’t collect or store your location — it’s only used on your device to place you on the map.")
                    .tutorialBodyStyle()
                    .accessibilityLabel("We do not collect or store your location. It is only used on your device to place you on the map.")
            }
        }
    }
}

#if DEBUG
#Preview {
    LocationPermissionView(locationManager: .init())
}
#endif
