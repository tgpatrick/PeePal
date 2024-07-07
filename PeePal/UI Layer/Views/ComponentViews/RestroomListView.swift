//
//  RestroomListView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/7/24.
//

import SwiftUI
import CoreLocation

struct RestroomListView: View {
    let restroom: Restroom
    let locationManager = LocationManager()

    private let disabledOpacity = 0.1

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(restroom.name ?? "(no name)")
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    HStack(spacing: 0) {
                        if let street = restroom.street {
                            Text(" ") + Text(street)
                        }
                        if let city = restroom.city {
                            Text(" ") + Text(city)
                        }
                        if let state = restroom.state {
                            Text(", ") + Text(state)
                        }
                    }
                    .font(.caption)
                    if let distance = getDistance() {
                        Text(String(distance))
                    }
                }
                Spacer()
                VStack {
                    HStack {
                        Image(.accessible)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(restroom.accessible ? 1 : 0.25)
                        Image(.changingTable)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(restroom.changingTable ? 1 : 0.25)
                    }
                    Image(.unisex)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(restroom.unisex ? 1 : 0.25)
                }
                .padding(5)
                .frame(width: 55, height: 55)
                .background {
                    AngularGradient(
                        colors: [
                            Color(.accessible)
                                .opacity(restroom.accessible ? 1 : disabledOpacity),
                            Color(.accessible)
                                .opacity(restroom.accessible ? 1 : disabledOpacity),
                            Color(.changingTable)
                                .opacity(restroom.changingTable ? 1 : disabledOpacity),
                            Color(.changingTable)
                                .opacity(restroom.changingTable ? 1 : disabledOpacity),
                            Color(.unisex)
                                .opacity(restroom.unisex ? 1 : disabledOpacity),
                            Color(.unisex)
                                .opacity(restroom.unisex ? 1 : disabledOpacity),
                            Color(.accessible)
                                .opacity(restroom.accessible ? 1 : disabledOpacity)
                        ],
                        center: .center,
                        angle: Angle(degrees: 180))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            Text(getPercent())
                .font(.caption2)
                .foregroundStyle(getColor())
        }
    }

    func getDistance() -> Double? {
        if let userLocation = locationManager.location {
            let restroomLocation = CLLocation(
                latitude: restroom.coordinate.latitude,
                longitude: restroom.coordinate.longitude)
            return userLocation.distance(from: restroomLocation)
        }
        return nil
    }

    func getColor() -> Color {
        if restroom.upvote > restroom.downvote {
            return Color(.changingTable)
        } else if restroom.upvote < restroom.downvote {
            return .red
        } else {
            return .secondary
        }
    }

    func getPercent() -> String {
        let total = restroom.upvote + restroom.downvote
        var percent: Double
        if total == 0 {
            return "Not Yet Rated"
        } else if restroom.upvote == restroom.downvote {
            return "Neutral Ratings"
        }
        percent = (Double(restroom.upvote) / Double(restroom.upvote + restroom.downvote)) * 100
        return String(Int(percent)) + "% Positive"
    }
}

#Preview {
    NavigationStack {
        List([exampleRestroom, exampleRestroom, exampleRestroom]) { restroom in
            RestroomListView(restroom: restroom)
        }
        .listStyle(.plain)
        .navigationTitle("Results")
    }
}
