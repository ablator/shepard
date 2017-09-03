//
//  shepard.swift
//  shepard is a client for the ablaator functionality switching server.
//  For more info, see http://github.com/ablator
//
//  Created by Daniel Jilg on 03.09.17.
//  Copyright © 2017 Daniel Jilg. All rights reserved.
//

import Foundation

public class AblatorClient {
    // MARK: - Properties
    
    private static var defaultAblatorClient: AblatorClient = {
        let ablatorClient = AblatorClient(baseURL: URL(string: "http://ablator.space")!)
        
        // Configuration
        // ...
        
        return ablatorClient
    }()
    
    // MARK: -
    
    let baseURL: URL
    
    // Initialization
    
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Accessors
    
    class func `default`() -> AblatorClient {
        return defaultAblatorClient
    }

}
