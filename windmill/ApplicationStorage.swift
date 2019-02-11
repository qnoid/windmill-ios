//
//  ApplicationStorage.swift
//  windmill
//
//  Created by Markos Charatzas on 25/09/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import Foundation
import os

struct ApplicationStorage {
    
    enum ApplicationStorageKey: String, CodingKey {
        case account = "account_identifier"
        case receiptClaim = "receipt_claim"
        case subscriptionAuthorizationToken = "subscription_authorization_token"
    }

    static let defaultURLResourceValues: URLResourceValues = {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        
        return resourceValues
    }()
    
    static let `default`: ApplicationStorage = {
        
        let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        do {
            try FileManager.default.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: false, attributes: [:])
        }
        catch let error as NSError {
            os_log("%{public}@", log: .default, type: .debug, error)
        }
        
        return ApplicationStorage(url: applicationSupportDirectory)
    }()
    
    let url: URL
    
    public func read(key: ApplicationStorageKey) throws -> String {
        return try String(contentsOf: self.url.appendingPathComponent(key.stringValue), encoding: .utf8)
    }
    
    public func write(value: String, key: ApplicationStorageKey, options: Data.WritingOptions = .completeFileProtectionUnlessOpen, resourceValues: URLResourceValues = ApplicationStorage.defaultURLResourceValues) throws {
        
        guard let data = value.data(using: .utf8) else {
            throw NSError()
        }
        
        var url = self.url.appendingPathComponent(key.stringValue)
        
        try data.write(to: url, options: options)
        try url.setResourceValues(resourceValues)
    }

    public func delete(key: ApplicationStorageKey) throws {
        
        let url = self.url.appendingPathComponent(key.stringValue)
     
        try FileManager.default.removeItem(at: url)
    }
}
