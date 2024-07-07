//
//  RestroomView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import SwiftUI

struct RestroomView: View {
    let restroom: Restroom
    @State var locationManager: LocationManager = LocationManager()

    var body: some View {
        ScrollView {
            RestroomListView(restroom: restroom, locationManager: locationManager)
                .padding(.horizontal)
        }
        .navigationTitle(restroom.name ?? "")
        .onAppear {
            UILabel.appearance(
                whenContainedInInstancesOf: [UINavigationBar.self]
            ).adjustsFontSizeToFitWidth = true
        }
    }
}

#Preview {
    NavigationStack {
        RestroomView(restroom: exampleRestroom)
    }
}
