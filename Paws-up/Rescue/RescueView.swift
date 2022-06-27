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
    var message: String = ""
    var timeStamp: String = ""
    var photo: Image = Image("denero")
    var petType: String = ""
    var zip : String = ""
    var id = UUID()
    var name = ""
    var coordinate = CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934)
}

struct MarkerView: View {
    @Binding var showingDetail: Bool
    @Binding var currentLocation: Location
    var location: Location
    var body: some View {
        
        ZStack {
            Button(action: {
                self.showingDetail = true
                currentLocation = location
            }) {
                Image("denero").resizable().frame(width: 40, height: 40).clipShape(Circle())
            }
        }
    }
}

struct SmallCardView: View {
    var location: Location
    @Binding var showingDetail: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("logo-pink"))
                .frame(width: UIScreen.main.bounds.size.width - 50, height: 160)
            Text(location.name).foregroundColor(.white)
            Button(action: {
                self.showingDetail = false
            }) {
                Image(systemName: "multiply").resizable()
                    .frame(width: 20.0, height: 20.0).foregroundColor(.white)
            }.offset(x: 140, y: -60)
        }
    }
}

struct RescueView: View {
    var mapView = MKMapView()
    let berkeley = Location(name: "Berkeley", coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934))
    let location1 = Location(name: "location1", coordinate: CLLocationCoordinate2D(latitude: 37.881684, longitude: -122.269934))
    let location2 = Location(name: "location2", coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.249934))
    var locations: [Location] = []
    @State var currentLocation = Location()
    init() {
        locations = [berkeley, location1, location2]
        currentLocation = berkeley
    }
    @State var showingDetail = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    MarkerView(showingDetail: $showingDetail, currentLocation: $currentLocation, location: location)
                }
            }
                .frame(width: 400, height: 600)
            if showingDetail {
                SmallCardView(location: currentLocation, showingDetail: $showingDetail).offset(y: UIScreen.main.bounds.size.height / 2 - 200)
            }
        }
    }
}

struct RescueView_Previews: PreviewProvider {
    static var previews: some View {
        RescueView()
    }
}
