//
//  RestroomListView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/15/20.
//

import SwiftUI
import CoreLocation

struct RestroomListView: View {
    let restroom: Restroom
    @State var locationManager = LocationManager()

    private let disabledOpacity = 0.1
    private var address: String {
        var address = ""
        if let street = restroom.street {
            address += street
        }
        if let city = restroom.city {
            address += " "
            address += city
        }
        if let state = restroom.state {
            address += ", "
            address += state
        }
        return address
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(restroom.name ?? "(no name)")
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    HStack(spacing: 0) {
                        Text(address)
                    }
                    .font(.caption)
                    .padding(.leading, 5)
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
            HStack(alignment: .center) {
                RatingView(restroom: restroom, small: true)
                if let distance = locationManager.distance(to: restroom.coordinate) {
                    Text(distance.formattedDistance())
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
            }
        }
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

extension CLLocationDistance {
    func formattedDistance(locale: Locale = .current) -> String {
        let meters = Measurement(value: self, unit: UnitLength.meters)

        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = locale
        measurementFormatter.unitOptions = .naturalScale
        measurementFormatter.unitStyle = .medium
        measurementFormatter.numberFormatter.maximumFractionDigits = 1

        // Determine if we should use imperial (miles) or metric (kilometers) system
        let useImperial = locale.measurementSystem == .us

        if useImperial {
            // Convert to miles for distances over 0.1 miles (about 160 meters)
            if self > 160 {
                let miles = meters.converted(to: .miles)
                return measurementFormatter.string(from: miles)
            } else {
                // For shorter distances, use feet
                let feet = meters.converted(to: .feet)
                measurementFormatter.numberFormatter.maximumFractionDigits = 0
                return measurementFormatter.string(from: feet)
            }
        } else {
            // Use kilometers for distances over 1000 meters
            if self >= 1000 {
                let kilometers = meters.converted(to: .kilometers)
                return measurementFormatter.string(from: kilometers)
            } else {
                // For shorter distances, use meters
                measurementFormatter.numberFormatter.maximumFractionDigits = 0
                return measurementFormatter.string(from: meters)
            }
        }
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
