//
//  shepard.swift
//  shepard is a client for the ablator functionality switching server.
//  For more info, see http://github.com/ablator
//
//  Created by Daniel Jilg on 03.09.17.
//  Copyright © 2017 Daniel Jilg. All rights reserved.
//

import Foundation

public class AblatorClient {
    // MARK: - Properties
    
    private static var defaultAblatorClient: AblatorClient = {
        let ablatorClient = AblatorClient(baseURL: string: "http://ablator.space/")
        
        // Configuration
        // ...
        
        return ablatorClient
    }()
    
    // MARK: -
    
    let baseURL: String
    
    // Initialization
    
    private init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - Accessors
    
    class func `default`() -> AblatorClient {
        return defaultAblatorClient
    }
    
    // MARK: - Caching
    
    func cachedFunctionalityFor(user: String, functionality: String) -> String? {
        // caching is not implemented yet
        return nil
    }
    
    // MARK: - Server Connections
    
    func urlForMethod(method: String, user: String, functionalityID: String) -> URL? {
        let urlString = "\(self.baseURL)api/v1/\(method)/\(user)/\(functionalityID)/"
        return URL(string: urlString)
    }
    
    func updateFunctionalityCacheFor(user: String, functionalityID: String, completed: @escaping ()->()) {
        let url = urlForMethod(method: "caniuse", user: user, functionalityID: functionalityID)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        print(stringData) //JSONSerialization
                    }
                }
                completed()
            })
            task.resume()
        }
    }
}
