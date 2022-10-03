//
//  MapDataSource.swift
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

class MapDataSource: DataSource {
    static let shared = MapDataSource()
    
    static var storageRef = Storage.storage().reference()
    
    @Published var locations: Array<MapModel.Location> = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    init() {
        MapDataSource.fetchLocations()
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
                let locations = querySnapshot!.documents.map { (document) -> MapModel.Location in
                    let dict = document.data()
                    return parseLocation(dict)
                }
                completion(locations)
                MapDataSource.shared.locations = locations
            }
        }
    }
    
    static func fetchLocations() {
        self.fetchItems { resources in
            print("done")
            for location in MapDataSource.shared.locations {
                print(location.id)
            }
        }
    }
    
    
    static func parseLocation(_ dict: [String: Any]) -> MapModel.Location {
        let dic = dict as! Dictionary<String, String>
        // Create a reference to the file you want to download
        print(dic["id"]!)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        var image = UIImage(named: "cat-portrait")
        image = dic["image"]?.imageFromBase64
        
        let coordinate = CLLocationCoordinate2D(latitude: Double(dic["lat"]!)!,
                                                longitude: Double(dic["long"]!)!)
        
        let location = MapModel.Location(id: dic["id"]!,
                                         username: dic["username"]!,
                                         title: dic["title"]!,
                                         description: dic["description"]!,
                                         image: image!,
                                         tags: dic["tags"]!,
                                         coordinate: coordinate,
                                         radius: Int(dic["radius"]!)!)
        
        return location
    }
}
