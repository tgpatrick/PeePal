//
//  RestroomView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import SwiftUI
import CoreLocation

struct RestroomView: View {
    @AppSetting(.directionsProvider) private var directionsProvider: DirectionsProvider
    
    let restroom: Restroom
    @State var locationManager = LocationManager()
    @State private var viewModel = RestroomViewModel()

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        if let street = restroom.street {
                            Text(street).fontWeight(.bold)
                        }
                        HStack(spacing: 0) {
                            if let city = restroom.city {
                                Text(city)
                            }
                            if let state = restroom.state {
                                Text(", " + state)
                            }
                            Spacer()
                        }
                    }
                    .font(.callout)
                    .fontDesign(.rounded)
                    Spacer()
                    if let distance = locationManager.distance(to: restroom.coordinate) {
                        Text(distance.formattedDistance())
                            .font(.title3)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }
                    Link(
                        destination: restroom.getDirectionsURL(
                            using: directionsProvider
                        )
                    ) {
                        Image(systemName: .directionsIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.black.opacity(0.9))
                    }
                    .frame(height: 50)
                    .modifier(GlassyOrProminentButton())
                }

                VStack {
                    HStack {
                        Spacer()
                        AvailabilityBadgeView(restroom: restroom)
                        Spacer()
                    }
                    RatingView(restroom: restroom)
                }

                TitledBoxView(
                    title: "Directions",
                    content: restroom.directions ?? "None")
                TitledBoxView(
                    title: "Comment",
                    content: restroom.comment ?? "None")

                VStack(spacing: 0) {
                    Text("Please note that PeePal cannot verify any of the information presented here. If you want to rate this restroom or propose an edit, please visit its page at")
                        .multilineTextAlignment(.center)
                    Link(destination: restroom.getRefugeRestroomsURL()) {
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("Refuge Restrooms")
                            Image(systemName: .externalLinkIcon)
                                .aspectRatio(contentMode: .fit)
                        }
                        .underline()
                        .foregroundStyle(Color(.unisex))
                        .bold()
                    }
                }
                .padding()
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .safeAreaPadding(.horizontal)
        }
        .navigationTitle(restroom.name ?? "")
        .onAppear {
            UILabel.appearance(
                whenContainedInInstancesOf: [UINavigationBar.self]
            ).adjustsFontSizeToFitWidth = true
        }
    }
}

#if DEBUG
#Preview {
    Color.accentColor.opacity(0.5).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ClusterSheetView(cluster: RestroomCluster(restrooms: [
                exampleRestroom
            ]), onSelectItem: nil, onDismiss: nil)
        }
}
#endif
