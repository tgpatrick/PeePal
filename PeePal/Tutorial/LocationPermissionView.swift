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
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: .locationCircleIcon)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("Share your location")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                
                Text("PeePal uses your current location to show where you are on the map and help you find nearby restrooms.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("We don’t collect or store your location — it’s only used on your device to place you on the map.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityLabel("We do not collect or store your location. It is only used on your device to place you on the map.")
            }
            
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    LocationPermissionView(locationManager: .init())
}
#endif
