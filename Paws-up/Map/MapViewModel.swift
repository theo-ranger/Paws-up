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
    private var mapModel: MapModel = MapModel()
    @Published var locationRepository = MapDataSource()
    
    let berkeley = MapModel.Location(id: "a",
                                        username: "aa",
                                        title: "world",
                                        description: "hello",
                                        image: UIImage(imageLiteralResourceName: "denero"),
                                        tags: "Berkeley",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
                                        radius: 10)
    let location1 = MapModel.Location(id: "b",
                                        username: "bb",
                                        title: "world",
                                        description: "hello",
                                        image: UIImage(imageLiteralResourceName: "denero"),
                                        tags: "Berkeley",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.881684, longitude: -122.269934),
                                        radius: 10)
    let location2 = MapModel.Location(id: "c",
                                        username: "cc",
                                        title: "world",
                                        description: "hello",
                                        image: UIImage(imageLiteralResourceName: "denero"),
                                        tags: "Berkeley",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.249934),
                                        radius: 10)
    
//    func addLocation(message: String, photo: UIImage, petType: String, zip: String, name: String, coordinate: CLLocationCoordinate2D, username: String,
//                 title: String) {
//        rescueModel.addLocation(message: message, photo: photo, petType: petType, zip: zip, name: name, coordinate: coordinate, username: username, title: title)
//    }
    func addLocation(username: String, title: String, description: String, image: UIImage, tags: String, coordinates: CLLocationCoordinate2D, radius: Int) {
        MapDataSource.addLocation(username: username, title: title, description: description, image: image, tags: tags, coordinates: coordinates, radius: radius)
    }
    
//    func fetchLocations() {
//        MapDataSource.fetchLocations()
//    }
}
