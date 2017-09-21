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
    /**
     Initialize the ablator client and update its cache.
     
     For Ablator to work, it needs a way to identify your user and the app it is
     running inside of. Also, the client needs to know which Ablator server to
     connect to.
     
     If you specify all three parameters, the client will immediately update its
     cache after it finishes initialization. If you don't supply username
     or appID on initialization, then you need to manually call the `updateCache`
     method after doing so.
     
     - parameter baseURL: The Ablator server's base URL. If you are using the hosted
       version, this is `http://ablator.space/`.
     - parameter username: A string that uniquely identifies your user. If your app
       does not have usernames, consider using `UIDevice.current.identifierForVendor!.uuidString`.
     - parameter appID: Your app's ID on ablator. You need to copy and paste this
       this from the ablator web interface.
     */
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
    
    /**
     Manually update the ablator cache.
     
     Takes an optional completion handler of type `([String]?) -> ()`,
     which gets the list of all enabled availabilities passed in if
     the request was successful.
     */
    public func updateCache(completed: completionHandlerType? = nil) {
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
    
    /**
     Can your user use the specified functionality?
     
     Use this if you only want to switch functionality on and off.
     Returns true if the specified functionality has at least one
     enabled availability, false otherwise.
     
     If the Ablator Client is not fully initialized, this method
     will always return false.
     
     - parameter functionalityName: The functionality fqdn, e.g.
       `yourorganization.yourapp.functionality`. You can copy this
       from the web interface.
     */
    public func canIUse(functionalityName: String) -> Bool {
        for availability in getCachedAvailabilityList() {
            if availability.starts(with: functionalityName) {
                return true
            }
        }
        return false
    }
    
    /**
     Which flavor of the functionality is enabled for your user,
     if any?
     
     Use this if you have defined more than one flavor in the
     ablator web interface.
     
     Returns the enabled flavor's fqdn string (e.g.
     `yourorganization.yourapp.functionality.flavor` if it
     is enabled, `nil` otherwise.
     
     If the Ablator Client is not fully initialized, this method
     will always return `nil`.
     
     - parameter functionalityName: The functionality fqdn, e.g.
       `yourorganization.yourapp.functionality`. You can copy this
       from the web interface.
     */
    public func which(functionalityName: String) -> String? {
        for availability in getCachedAvailabilityList() {
            if availability.starts(with: functionalityName) {
                return availability
            }
        }
        return nil
    }
    
}
