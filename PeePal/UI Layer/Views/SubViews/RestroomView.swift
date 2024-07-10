//
//  RestroomView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import SwiftUI
import CoreLocation

struct RestroomView: View {
    @Environment(\.colorScheme) private var colorScheme
    let restroom: Restroom
    @State var locationManager: LocationManager = LocationManager()

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
                    Link(destination: AppLogic.makeAppleMapsURL(restroom: restroom)) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(.black).opacity(0.9))
                        .padding(10)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                        )
                        .cornerRadius(10)
                        .adaptiveShadow(radius: 5)
                    }
                }

                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 0) {
                            availabilityBadge(for: .unisex, isAvailable: restroom.unisex)
                            availabilityBadge(for: .accessible, isAvailable: restroom.accessible)
                            availabilityBadge(for: .changingTable, isAvailable: restroom.changingTable)
                        }
                        .background(badgesBackground)
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
                    Link(destination: AppLogic.makeEditURL(restroom: restroom)) {
                        HStack(spacing: 2) {
                            Text("Refuge Restrooms")
                            Image(systemName: "arrow.up.forward.square")
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

    private var badgesBackground: some View {
        Rectangle()
            .background(
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(
                            Color(.unisex).opacity(restroom.unisex ? 1 : 0.1)
                        )
                    Rectangle()
                        .foregroundStyle(
                            Color(.accessible).opacity(restroom.accessible ? 1 : 0.1)
                        )
                        .zIndex(2)
                    Rectangle()
                        .foregroundStyle(
                            Color(.accessible).opacity(restroom.accessible ? 1 : 0.1)
                        )
                        .zIndex(2)
                    Rectangle()
                        .foregroundStyle(
                            Color(.changingTable).opacity(restroom.changingTable ? 1 : 0.1)
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func availabilityBadge(for imageResource: ImageResource, isAvailable: Bool) -> some View {
        imageInvertedIfDark(image: Image(imageResource))
            .padding(10)
            .frame(width: 50, height: 50)
            .opacity(isAvailable ? 1 : 0.1)
    }

    private func imageInvertedIfDark(image: Image) -> some View {
        Group {
            if colorScheme == .dark {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

#Preview {
    Color.accentColor.opacity(0.5).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(RestroomCluster(restrooms: [
                    exampleRestroom])))
        }
}
