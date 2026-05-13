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
        return Image(systemName: mapItem.iconName)
            .font(.system(size: 22))
            .frame(width: 55, height: 55)
            .foregroundColor(.black)
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

extension MKMapItem {
    var iconName: String {
        var iconName: String

        switch pointOfInterestCategory {
            // Arts and culture
        case .museum:
            iconName = "building.columns.fill"
        case .theater:
            iconName = "theatermasks.fill"
            
            // Education
        case .library:
            iconName = "building.columns.fill"
        case .school:
            iconName = "building.2.fill"
        case .university:
            iconName = "graduationcap.fill"
            
            // Entertainment
        case .movieTheater:
            iconName = "popcorn.fill"
        case .nightlife:
            iconName = "moon.stars.fill"
            
            // Health and safety
        case .fireStation:
            iconName = "house.and.flag.fill"
        case .hospital:
            iconName = "cross.fill"
        case .pharmacy:
            iconName = "pills.fill"
        case .police:
            iconName = "shield.fill"
            
            // Food and drink
        case .bakery:
            iconName = "birthday.cake.fill"
        case .brewery:
            iconName = "mug.fill"
        case .cafe:
            iconName = "fork.knife"
        case .foodMarket:
            iconName = "cart.fill"
        case .restaurant:
            iconName = "fork.knife"
        case .winery:
            iconName = "wineglass.fill"
            
            // Personal services
        case .atm:
            iconName = "banknote.fill"
        case .bank:
            iconName = "dollarsign.bank.building.fill"
        case .evCharger:
            iconName = "ev.charger.fill"
        case .fitnessCenter:
            iconName = "dumbbell.fill"
        case .laundry:
            iconName = "hanger"
        case .postOffice:
            iconName = "envelope.fill"
        case .restroom:
            iconName = "toilet.fill"
        case .store:
            iconName = "cart"
            
            // Parks and recreation
        case .amusementPark:
            iconName = "seal"
        case .aquarium:
            iconName = "fish.fill"
        case .beach:
            iconName = "beach.umbrella.fill"
        case .campground:
            iconName = "tent.2.fill"
        case .marina:
            iconName = "sailboat.fill"
        case .nationalPark:
            iconName = "tree.fill"
        case .park:
            iconName = "tree.fill"
        case .zoo:
            iconName = "pawprint.fill"
            
            // Sports
        case .stadium:
            iconName = "circle.dotted.circle"
            
            // Travel
        case .airport:
            iconName = "airplane"
        case .carRental:
            iconName = "car.2.fill"
        case .gasStation:
            iconName = "fuelpump.fill"
        case .hotel:
            iconName = "bed.double"
        case .parking:
            iconName = "parkingsign.circle.fill"
        case .publicTransport:
            iconName = "bus.fill"
        default:
            iconName = .mapPinIcon
        }
        
        if #available(iOS 18.0, *) {
            switch pointOfInterestCategory {
                //Arts and culture
            case .musicVenue:
                iconName = "music.microphone"
                
                //Education
            case .planetarium:
                iconName = "globe.desk.fill"
                
                // Historical and cultural landmarks
            case .castle:
                iconName = "building.columns.fill"
            case .fortress:
                iconName = "building.columns.fill"
            case .landmark:
                iconName = "building.columns.fill"
            case .nationalMonument:
                iconName = "building.columns.fill"
                
                // Food and drink
            case .distillery:
                iconName = "mug.fill"
                
                // Personal services
            case .animalService:
                iconName = "dog.fill"
            case .automotiveRepair:
                iconName = "car.side.front.open.fill"
            case .beauty:
                iconName = "scissors"
            case .mailbox:
                iconName = "envelope.front.fill"
            case .spa:
                iconName = "water.waves"
                
                //Parks and recreation
            case .fairground:
                iconName = "seal"
            case .rvPark:
                iconName = "bus.doubledecker.fill"

                //Sports
            case .baseball:
                iconName = "baseball.fill"
            case .basketball:
                iconName = "basketball.fill"
            case .bowling:
                iconName = "figure.bowling"
            case .goKart:
                iconName = "road.lanes.curved.right"
            case .golf:
                iconName = "figure.golf"
            case .hiking:
                iconName = "figure.hiking"
            case .miniGolf:
                iconName = "figure.golf"
            case .rockClimbing:
                iconName = "figure.climbing"
            case .skatePark:
                iconName = "figure.skateboarding"
            case .skating:
                iconName = "figure.ice.skating"
            case .skiing:
                iconName = "figure.skiing.downhill"
            case .soccer:
                iconName = "soccerball"
            case .tennis:
                iconName = "figure.tennis"
            case .volleyball:
                iconName = "volleyball.fill"
                
                // Travel
            case .conventionCenter:
                iconName = "seal"

                // Water sports
            case .fishing:
                iconName = "figure.fishing"
            case .kayaking:
                iconName = "water.waves"
            case .surfing:
                iconName = "figure.surfing"
            case .swimming:
                iconName = "figure.pool.swim"
            default:
                iconName = .mapPinIcon
            }
        }
        
        return iconName
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        List([exampleRestroom, exampleRestroom, exampleRestroom]) { restroom in
            ListItemView(listItem: restroom)
        }
        .listStyle(.plain)
        .navigationTitle("Results")
    }
}
#endif
