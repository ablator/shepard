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
    let cacheFileName = "AblatorCache.plist"
    
    // Initialization
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - Accessors
    
    class func `default`() -> AblatorClient {
        return defaultAblatorClient
    }
    
    public func caniuse(user: String, functionalityID: String, completed: completionHandlerType? = nil) -> Bool {
        if which(user: user, functionalityID: functionalityID) != nil {
            return true
        }
        return false
    }
    
    public func which(user: String, functionalityID: String, completed: completionHandlerType? = nil) -> String? {
        updateFunctionalityCacheFor(user: user, functionalityID: functionalityID, completed: completed)
        return cachedFunctionalityFor(user: user, functionalityID: functionalityID)
    }
    
    // MARK: - Caching
    
    func cachedFunctionalityFor(user: String, functionalityID: String) -> String? {
        let cacheDict = getCacheDict()
        let functionalityString = cacheDict[cacheKeyFor(user: user, functionalityID: functionalityID)] ?? nil
        return functionalityString
    }
    
    func cacheFunctionalityFor(user: String, functionalityID: String, functionalityString: String?) {
        var cacheDict = getCacheDict()
        cacheDict[cacheKeyFor(user: user, functionalityID: functionalityID)] = functionalityString
        saveCacheDict(cacheDict: cacheDict)
        
    }
    
    private func cacheKeyFor(user: String, functionalityID: String) -> String {
        return "\(functionalityID)---\(user)"
    }
    
    private func getCacheDict() -> [String: String?] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(self.cacheFileName)
        if let cacheDict = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL!.path) as? [String: String?] {
            return cacheDict
        } else {
            return [String: String?]()
        }
    }
    
    private func saveCacheDict(cacheDict: [String: String?]) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(self.cacheFileName)
        NSKeyedArchiver.archiveRootObject(cacheDict, toFile: fileURL!.path)
    }
    
    // MARK: - Server Connections
    
    
    func urlForMethod(method: String, user: String, functionalityID: String) -> URL? {
        let urlString = "\(self.baseURL)api/v1/\(method)/\(user)/\(functionalityID)/"
        return URL(string: urlString)
    }
    
    public typealias completionHandlerType = (String?) -> ()
    
    func updateFunctionalityCacheFor(user: String, functionalityID: String, completed: completionHandlerType?) {
        let url = urlForMethod(method: "which", user: user, functionalityID: functionalityID)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                var functionalityString: String? = nil
                if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonDict = json as? [String: Any] {
                    if let functionality = jsonDict["functionality"] as? String? {
                        functionalityString = functionality
                        self.cacheFunctionalityFor(user: user, functionalityID: functionalityID, functionalityString: functionalityString)
                    }
                }
                completed?(functionalityString)
            })
            task.resume()
        }
    }
}
