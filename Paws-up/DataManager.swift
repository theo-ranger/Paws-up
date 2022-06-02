//
//  DataManager.swift
//  Paws-up
//
//  Created by 那桐 on 6/1/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

protocol DataSource {
    typealias completionHandler = (_ resources: [Any]) -> Void
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    // dispatch group to ensure data sources only fetch from Firebase once
    static var fetchDispatch: DispatchGroup { get set }
}

struct Content: Identifiable {
    var id: String
    var timeStamp: String
    var title: String
    var userName: String
    var image: UIImage
}

class PostDataSource: DataSource
{
    static var storageRef = Storage.storage().reference()
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("post fetch")
        let db = Firestore.firestore()
        
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ PostDataSource.fetchItems()]: \(err)")
                return
            } else {
                let posts = querySnapshot!.documents.map { (document) -> Content in
                    let dict = document.data()
                    return parsePost(dict)
                }
                completion(posts)
            }
        }
    }
    
    // Return a Gym object parsed from a dictionary.
    private static func parsePost(_ dict: [String: Any]) -> Content {
        let dic = dict as! Dictionary<String, String>
        // Create a reference to the file you want to download
        let childRef = self.storageRef.child(dic["id"]!)
        print("ddddddd")
        print(dic["id"]!)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        var image = UIImage(named: "cat-portrait")
        childRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
              print("image fetch error")
          } else {
            // Data for "images/island.jpg" is returned
            image = UIImage(data: data!)!
          }
        }
        
        let post = Content(id: dic["id"]!, timeStamp: dic["timeStamp"]!, title: dic["title"]!, userName: dic["username"]!, image: image!)
        
        return post
    }
}

/** The list of `DataSource` classes to fetch data from. Add to this list to add new data to the app. */
fileprivate let kDataSources: [DataSource.Type] = [
    PostDataSource.self
]

class DataManager {
    
    /** Singleton instance */
    static let shared = DataManager()
    
    private var data: Dictionary<String, [Any]>
    
    private init() {
        data = Dictionary<String, [Any]>()
    }
    
    private func asKey(_ source: DataSource.Type) -> String {
        return String(describing: source)
    }
    
    func fetchAll() {
        let requests = DispatchGroup()
        for source in kDataSources {
            requests.enter()
            fetch(source: source) { _ in requests.leave() }
        }
    }

    func fetch(source: DataSource.Type, _ completion: @escaping DataSource.completionHandler) {
        // make sure that all data sources are only fetched form Firebase once
        // this also prevents issues with having two objects for the same library overriding each other
        let dispatch = source.fetchDispatch
        dispatch.notify(queue: .global(qos: .utility)) {
            // if data source already loaded, use existing item
            if let items = self.data[self.asKey(source)] {
                DispatchQueue.main.async {
                    completion(items)
                }
            } else {
                // if this is the first time fetching for this source, pause all other fetches and get data from Firebase
                dispatch.enter()
                source.fetchItems { items in
                    self.data[self.asKey(source)] = items
                    DispatchQueue.main.async {
                        dispatch.leave()
                        completion(items)
                        print("datamanager self.data")
                        print(self.data)
                    }
                }
            }
        }
    }
    
}
