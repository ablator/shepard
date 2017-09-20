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
    
    // MARK: - Configuration
    
    let baseURL: String
    var username: String?
    var appID: String?
    let cacheFileName = "AblatorCacheList.plist"
    
    // MARK: - Initialization
    
    public init(baseURL: String, username: String? = nil, appID: String? = nil) {
        self.baseURL = baseURL
        self.username = username
        self.appID = appID
        
        self.updateCache()
    }
    
    class func `default`() -> AblatorClient {
        return defaultAblatorClient
    }
    
    // MARK: - Retrieval from Server
    
    func urlForMethod(method: String, user: String, appID: String) -> URL? {
        let urlString = "\(self.baseURL)api/v2/\(method)/\(user)/\(appID)/"
        return URL(string: urlString)
    }
    
    public typealias completionHandlerType = ([String]?) -> ()
    
    func updateCache(completed: completionHandlerType? = nil) {
        guard let appID = self.appID else { debugPrint("Ablator: App ID not defined, cancelling request."); return }
        guard let username = self.username else { debugPrint("Ablator: Username not defined, cancelling request."); return }
        guard let url = urlForMethod(method: "which", user: username, appID: appID) else {
            debugPrint("Ablator: Could not create URL, cancelling request.")
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else { debugPrint("Ablator: Did not receive data from the server."); return }
            
            do {
                let decoder = JSONDecoder()
                let availabilities = try decoder.decode([String].self, from: data)
                self.saveCachedAvailabilityList(availabilityList: availabilities)
                completed?(availabilities)
            }
            catch {
                debugPrint("Ablator: Error while parsing JSON from the server.")
                return
            }
        })
        task.resume()
    }
    
    // MARK: - Caching
    
    private func getCachedAvailabilityList() -> [String] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(self.cacheFileName)
        if let cachedAvailabilities = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL!.path) as? [String] {
            return cachedAvailabilities
        } else {
            return [String]()
        }
    }
    
    private func saveCachedAvailabilityList(availabilityList: [String]) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(self.cacheFileName)
        NSKeyedArchiver.archiveRootObject(availabilityList, toFile: fileURL!.path)
    }
    
    // MARK: - Public Methods
    
    public func canIUse(functionalityName: String) -> Bool {
        for availability in getCachedAvailabilityList() {
            if availability.starts(with: functionalityName) {
                return true
            }
        }
        return false
    }
    
    public func which(functionalityName: String) -> String? {
        for availability in getCachedAvailabilityList() {
            if availability.starts(with: functionalityName) {
                return availability
            }
        }
        return nil
    }
    
}
