//
//  DataManager.swift
//  Paws-up
//
//  Created by Hanning Xu on 7/3/22.
//

import Foundation

protocol DataSource {
    typealias completionHandler = (_ resources: [Any]) -> Void
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    // dispatch group to ensure data sources only fetch from Firebase once
    static var fetchDispatch: DispatchGroup { get set }
}

fileprivate let allDataSources: [DataSource.Type] = [
    //PostRepository.self,
    RescueDataSource.self
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
        for source in allDataSources {
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
