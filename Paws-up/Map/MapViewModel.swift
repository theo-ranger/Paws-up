//
//  MapViewModel.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import MapKit
import SwiftUI

class MapViewModel {
    private var rescueModel: MapModel = MapModel()
    @Published var locationRepository = MapDataSource()
    
    let berkeley = MapModel.Location(message: "",
                                        timeStamp: "",
                                        photo: UIImage(imageLiteralResourceName: "denero"),
                                        petType: "",
                                        zip: "",
                                        id: "",
                                        name: "Berkeley",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
                                        username: "",
                                        title: "")
    let location1 = MapModel.Location(message: "",
                                         timeStamp: "",
                                         photo: UIImage(imageLiteralResourceName: "denero"),
                                         petType: "",
                                         zip: "",
                                         id: "",
                                         name: "location1",
                                         coordinate: CLLocationCoordinate2D(latitude: 37.881684, longitude: -122.269934),
                                         username: "",
                                         title: "")
    let location2 = MapModel.Location(message: "",
                                        timeStamp: "",
                                         photo: UIImage(imageLiteralResourceName: "denero"),
                                        petType: "",
                                        zip: "",
                                        id: "",
                                        name: "location2",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.249934),
                                        username: "",
                                        title: "")
    
    func addLocation(message: String, photo: UIImage, petType: String, zip: String, name: String, coordinate: CLLocationCoordinate2D, username: String,
                 title: String) {
        rescueModel.addLocation(message: message, photo: photo, petType: petType, zip: zip, name: name, coordinate: coordinate, username: username, title: title)
    }
    
    func fetchLocations() {
        MapDataSource.fetchLocations()
    }
}
