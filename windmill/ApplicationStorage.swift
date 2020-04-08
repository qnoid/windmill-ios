//
//  ApplicationStorage.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 25/09/2017.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

import Foundation
import os

struct ApplicationStorage {
    
    enum ApplicationStorageKey: String, CodingKey {
        case account = "account_identifier"
        case subscriptionClaim = "subscription_claim"
        case subscriptionAuthorizationToken = "subscription_authorization_token"
    }

    static let defaultURLResourceValues: URLResourceValues = {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        
        return resourceValues
    }()
    
    static let `default`: ApplicationStorage = {
        
        let applicationSupportDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        if FileManager.default.fileExists(atPath: applicationSupportDirectoryURL.path) {
            return ApplicationStorage(url: applicationSupportDirectoryURL)
        } else {
            do {
                try FileManager.default.createDirectory(at: applicationSupportDirectoryURL, withIntermediateDirectories: false, attributes: [:])
            }
            catch let error as NSError {
                os_log("%{public}@", log: .default, type: .debug, error)
            }
        }
        
        return ApplicationStorage(url: applicationSupportDirectoryURL)
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
