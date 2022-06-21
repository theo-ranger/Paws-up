//
//  RescueView.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import SwiftUI
import MapKit

struct RescueView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [.all])
            .frame(width: 400, height: 600)
    }
}
