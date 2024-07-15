//
//  RestroomListView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/15/20.
//

import SwiftUI
import MapKit

struct ListItemView: View {
    let listItem: any Listable
    @State var locationManager = LocationManager()
    
    private var restroomData: Restroom? {
        listItem as? Restroom
    }
    private var mapItemData: MKMapItem? {
        listItem as? MKMapItem
    }

    private let disabledOpacity = 0.1

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(listItem.fullName)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    HStack(spacing: 0) {
                        Text(listItem.fullAddress)
                    }
                    .font(.caption)
                    .padding(.leading, 5)
                }
                Spacer()
                if let restroomData {
                    availabilityIndicator(restroom: restroomData)
                } else if let mapItemData {
                    mapItemPin(mapItem: mapItemData)
                }
            }
            HStack(alignment: .center) {
                if let distance = locationManager.distance(to: listItem.coordinate) {
                    Text(distance.formattedDistance())
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                if let restroomData {
                    RatingView(restroom: restroomData, small: true)
                }
            }
        }
    }

    private func availabilityIndicator(restroom: Restroom) -> some View {
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

    private func mapItemIconname(for mapItem: MKMapItem) -> String {
        let iconName: String

        if mapItem.pointOfInterestCategory == .airport {
            iconName = "airplane"
        } else if mapItem.pointOfInterestCategory == .restaurant {
            iconName = "fork.knife"
        } else if mapItem.pointOfInterestCategory == .hotel {
            iconName = "bed.double"
        } else if mapItem.pointOfInterestCategory == .store {
            iconName = "cart"
        } else {
            iconName = "mappin"
        }

        return iconName
    }

    private func mapItemPin(mapItem: MKMapItem) -> some View {
        return Image(systemName: mapItemIconname(for: mapItem))
            .font(.system(size: 22))
            .frame(width: 55, height: 55)
            .foregroundColor(.primary)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension CLLocationDistance {
    func formattedDistance(locale: Locale = .current) -> String {
        let meters = Measurement(value: self, unit: UnitLength.meters)
        let formatStyle = Measurement<UnitLength>.FormatStyle(width: .wide, usage: .road)

        return meters.formatted(formatStyle)
    }
}

#Preview {
    NavigationStack {
        List([exampleRestroom, exampleRestroom, exampleRestroom]) { restroom in
            ListItemView(listItem: restroom)
        }
        .listStyle(.plain)
        .navigationTitle("Results")
    }
}
