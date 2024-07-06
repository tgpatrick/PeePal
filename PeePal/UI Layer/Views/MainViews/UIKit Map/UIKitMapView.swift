//
//  UIKitMapView.swift
//  PeePal
//
//  Created by Thomas Patrick on 1/29/21.
//

import Foundation
import SwiftUI
import MapKit
/*
final class UIKitRestroom: NSObject, MKAnnotation {
    var id: Int
    var name: String?
    var street: String?
    var city: String?
    var state: String?
    var accessible: Bool
    var unisex: Bool
    var changing_table: Bool
    var distance: Float?
    var comment: String?
    var directions: String?
    var downvote: Int
    var upvote: Int
    let coordinate: CLLocationCoordinate2D
    
    init(restroom: Restroom) {
        id = restroom.id
        name = restroom.name
        street = restroom.street
        city = restroom.city
        state = restroom.state
        accessible = restroom.accessible
        unisex = restroom.unisex
        changing_table = restroom.changing_table
        distance = restroom.distance
        comment = restroom.comment
        directions = restroom.directions
        downvote = restroom.downvote
        upvote = restroom.upvote
        coordinate = restroom.getCoordinates()
    }
    
    static func convert(normalRestrooms: [Restroom]) -> [UIKitRestroom] {
        var returnValue: [UIKitRestroom] = []
        for restroom in normalRestrooms {
            returnValue.append(UIKitRestroom(restroom: restroom))
        }
        return returnValue
    }
}

struct MapView: UIViewRepresentable {
    var locationManager = CLLocationManager()
    var normalRestrooms: [Restroom]
    @Binding var restrooms: [UIKitRestroom]
    
    struct ContentViewAdvance: View {
        @State var restrooms: [UIKitRestroom] = UIKitRestroom.convert(normalRestrooms: normalRestrooms)
      
      var body: some View {
        MapView(restrooms: $restrooms)
      }
    }
    
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupManager()
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.addAnnotations(restrooms)
    }
}
*/
