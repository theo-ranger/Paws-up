//
//  Paws_upApp.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI
import Firebase
import MapKit
import Foundation

@main
struct Paws_upApp: App {
    
    init() {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            //MapTestView(place: IdentifiablePlace(lat: 37.871684, long: -122.259934), region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
        }
    }
}
