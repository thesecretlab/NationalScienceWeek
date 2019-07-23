//
//  Feed.swift
//  Science Week
//
//  Created by Mars Geldard on 20/7/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

typealias DataHandlerCompletion = ((Data?, URLResponse?, Error?) -> Void)

final class FeedHandler {
    
    private let shared = FeedHandler()

    private init() {}
    
    static func requestContent(completion: @escaping DataHandlerCompletion) {
        let task = URLSession.shared.dataTask(with: URL.rssFeedURL) { data, response, error in
            completion(data, response, error)
        }
        
        task.resume()
    }
}


