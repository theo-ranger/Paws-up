//
//  DataSource.swift
//  Paws-up
//
//  Created by Hanning Xu on 5/26/22.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation

protocol DataSource {
    typealias completionHandler = (_ resources: [Any]) -> Void
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    // dispatch group to ensure data sources only fetch from Firebase once
    static var fetchDispatch: DispatchGroup { get set }
}
