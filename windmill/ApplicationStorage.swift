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
    
    public func read(key: String) throws -> String {
        return try String(contentsOf: self.url.appendingPathComponent(key), encoding: .utf8)
    }
    
    public func write(value: Data, key: String, resourceValues: URLResourceValues = ApplicationStorage.defaultURLResourceValues) throws {
        
        var url = self.url.appendingPathComponent(key)
        
        try value.write(to: url, options: .completeFileProtectionUnlessOpen)
        try url.setResourceValues(resourceValues)
    }

    public func delete(key: String) throws {
        
        let url = self.url.appendingPathComponent(key)
     
        try FileManager.default.removeItem(at: url)
    }
}
