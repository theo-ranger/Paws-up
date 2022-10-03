//
//  MapModel.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import SwiftUI
import MapKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

struct MapModel {
    
    struct Location: Identifiable {
        var id: String
        var username: String
        var title: String
        var description: String
        var image: UIImage
        var tags: String
        var coordinate: CLLocationCoordinate2D
        var radius: Int
    }
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    // MARK: -Intent(s)
    
    func addLocation(username: String, title: String, description: String, image: UIImage, tags: String, coordinates: CLLocationCoordinate2D, radius: Int) {
        print(coordinates)
        let uid = UUID().uuidString
        db.collection("locations").document(uid).setData([
            "id": uid,
            "timeStamp": String(NSDate().timeIntervalSince1970),
            "username": username,
            "title": title,
            "description": description,
            "image": String(image.base64!),
            "tags": tags,
            "lat": String(coordinates.latitude),
            "long": String(coordinates.longitude),
            "radius": String(radius)
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
//    func addLocation1(message: String, photo: UIImage, petType: String, zip: String, name: String, coordinate: CLLocationCoordinate2D, username: String,
//        title: String) {
//        let uid = UUID().uuidString
//        db.collection("locations").document(uid).setData([
//            "id": uid,
//            "timeStamp": String(NSDate().timeIntervalSince1970),
//            "username": username,
//            "title": title,
//            "photo": String(photo.base64!),
//            "message": message,
//            "petType": petType,
//            "zip": zip,
//            "name": name,
//            "latitude": String(coordinate.latitude),
//            "longitude": String(coordinate.longitude)
//        ]) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("Document successfully written!")
//            }
//        }
//    }
}
