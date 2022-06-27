//
//  RescueView.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RedCircleView: View {
    var body: some View {
        Circle()
            .stroke(.red, lineWidth: 3)
            .frame(width: 44, height: 44)
    }
}

struct RescueView: View {
    var mapView = MKMapView()
    let locations = [Location(name: "Berkeley", coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934))]
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                RedCircleView()
            }
        }
            .frame(width: 400, height: 600)
    }
}
