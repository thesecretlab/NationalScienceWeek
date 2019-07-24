//
//  Feed.swift
//  Science Week
//
//  Created by Mars Geldard on 20/7/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

typealias DataHandlerCompletion = ((Data?) -> Void)

final class FeedHandler {
    
    private static let shared = FeedHandler()
    private var lastModifiedDate: Date? = nil

    private init() {}
    
    static func requestContent(completion: @escaping DataHandlerCompletion) {
        FeedHandler.shared.requestContent(completion: completion)
    }
    
    private func requestContent(completion: @escaping DataHandlerCompletion) {
        if lastModifiedDate == nil {
            self.fetchContent(completion: completion)
            return
        }
        
        getLastUpdated { date in
            if self.lastModifiedDate == nil ||
                date == nil ||
                self.lastModifiedDate != date {
                self.fetchContent(completion: completion)
            }
            
            if date != nil {
                self.lastModifiedDate = date
            }
        }
    }
    
    private func fetchContent(completion: @escaping DataHandlerCompletion) {
        let task = URLSession.shared.dataTask(with: URL.rssFeedURL) { data, response, error in
            if let data = data, error == nil, // if data exists AND there was no error
                let httpResponse = response as? HTTPURLResponse, // AND the HTTP response code was valid
                200..<300 ~= httpResponse.statusCode { // AND it indicated success
                
                // parse data
                
                completion(data)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private func getLastUpdated(completion: @escaping (Date?) -> Void) {
        var request = URLRequest(url: URL.rssFeedURL)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if error == nil, // if there was no error
                let httpResponse = response as? HTTPURLResponse, // AND the HTTP response code was valid
                200..<300 ~= httpResponse.statusCode, // AND it indicated success
                let lastModified = httpResponse.allHeaderFields["Last-Modified"], // AND it had the field
                let lastModifiedDate = lastModified as? String { // and it contained data
                
                
                let date = Date()
                print("\n\n\n\n" + lastModifiedDate + "\n\n\n\n")
                completion(date)

                
                
                // parse date
                
                
                
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
}


