//
//  RescueDataSource.swift
//  Paws-up
//
//  Created by Hanning Xu on 7/3/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
import MapKit

let rescueDataSource = "locations"

class RescueDataSource: DataSource {
    static let shared = RescueDataSource()
    
    static var storageRef = Storage.storage().reference()
    
    @Published var locations: Array<RescueModel.Location> = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    init() {
        RescueDataSource.fetchLocations()
    }
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("location fetch")
        let db = Firestore.firestore()
        
        db.collection(rescueDataSource).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ PostDataSource.fetchItems()]: \(err)")
                return
            } else {
                let locations = querySnapshot!.documents.map { (document) -> RescueModel.Location in
                    let dict = document.data()
                    return parseLocation(dict)
                }
                completion(locations)
                RescueDataSource.shared.locations = locations
            }
        }
    }
    
    static func fetchLocations() {
        self.fetchItems { resources in
            print("done")
            for location in RescueDataSource.shared.locations {
                print(location.id)
            }
        }
    }
    
    
    static func parseLocation(_ dict: [String: Any]) -> RescueModel.Location {
        let dic = dict as! Dictionary<String, String>
        // Create a reference to the file you want to download
        print(dic["id"]!)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        var photo = UIImage(named: "cat-portrait")
        photo = dic["photo"]?.imageFromBase64
        
        let coordinate = CLLocationCoordinate2D(latitude: Double(dic["latitude"]!)!,
                                                longitude: Double(dic["longitude"]!)!)
        
        let location = RescueModel.Location(message: dic["message"]!,
                                            timeStamp: dic["timeStamp"]!,
                                            photo: photo!,
                                            petType: dic["petType"]!,
                                            zip: dic["zip"]!,
                                            id: dic["id"]!,
                                            name: dic["name"]!,
                                            coordinate: coordinate,
                                            username: dic["username"]!,
                                            title: dic["title"]!)
        
        return location
    }
}
