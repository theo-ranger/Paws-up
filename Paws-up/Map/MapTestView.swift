//
//  MapTestView.swift
//  Paws-up
//
//  Created by Hanning Xu on 7/31/22.
//

import Foundation
import SwiftUI
import MapKit
import MapItemPicker

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}

struct MapTestView: View {
    let place: [IdentifiablePlace]
    @State var region: MKCoordinateRegion
    @State private var showingPicker = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                annotationItems: place)
            { place in
                MapAnnotation(coordinate: place.location) {
                    Image("denero")
                    let _ = print(region.center)
                }
            }
            
            Button("Choose location") {
                showingPicker = true
            }
            .mapItemPicker(isPresented: $showingPicker) { item in
                if let name = item?.name {
                    print("Selected \(name)")
                }
            }
            
            Image(systemName: "mappin.and.ellipse")
                .font(.largeTitle)
                .foregroundColor(Color("logo-pink"))
        }
    }
}

