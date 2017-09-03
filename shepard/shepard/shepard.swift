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
        let ablatorClient = AblatorClient(baseURL: "http://ablator.space/")
        return ablatorClient
    }()
    
    // MARK: -
    
    let baseURL: String
    
    // Initialization
    
    public init(baseURL: String) {
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
    
    func updateCaches() {
        
    }
    
    func urlForMethod(method: String, user: String, functionalityID: String) -> URL? {
        let urlString = "\(self.baseURL)api/v1/\(method)/\(user)/\(functionalityID)/"
        return URL(string: urlString)
    }
    
    public typealias completionHandlerType = () -> ()
    
    public func updateFunctionalityCacheFor(user: String, functionalityID: String, completed: completionHandlerType?) {
        let url = urlForMethod(method: "which", user: user, functionalityID: functionalityID)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        print(stringData) //JSONSerialization
                    }
                }
                completed?()
            })
            task.resume()
        }
    }
}
