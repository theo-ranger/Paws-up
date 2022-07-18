//
//  RescueViewModel.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import MapKit
import SwiftUI

class RescueViewModel {
    private var rescueModel: RescueModel = RescueModel()
    @Published var locationRepository = RescueDataSource()
    
    let berkeley = RescueModel.Location(message: "",
                                        timeStamp: "",
                                        photo: UIImage(imageLiteralResourceName: "denero"),
                                        petType: "",
                                        zip: "",
                                        id: "",
                                        name: "Berkeley",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
                                        username: "",
                                        title: "")
    let location1 = RescueModel.Location(message: "",
                                         timeStamp: "",
                                         photo: UIImage(imageLiteralResourceName: "denero"),
                                         petType: "",
                                         zip: "",
                                         id: "",
                                         name: "location1",
                                         coordinate: CLLocationCoordinate2D(latitude: 37.881684, longitude: -122.269934),
                                         username: "",
                                         title: "")
    let location2 = RescueModel.Location(message: "",
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
        RescueDataSource.fetchLocations()
    }
}
