//
//  CloudKitManager.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 17/03/2019.
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
import CloudKit
import os

extension CKError {
    

    /**
     A fatal server error.
     
     You should correct the CKOperation before trying again.
    */
    func isFatalServerError() -> Bool {

        return self.code == CKError.internalError ||
            self.code == CKError.serverRejectedRequest ||
            self.code == CKError.invalidArguments ||
            self.code == CKError.permissionFailure
    }
    /**
     A retry server error.
     
     Reinitialise the same CLOperation, with the same arguments and retry.
     You should try again after 'x' seconds in CKRetryErrorRetryAfterKey as Double in error's userInfo dictionary.
     
     Alternatively, add a `CKOperation` to the `CKDatabase` which automatically retries.
    */
    func isRetryServerError() -> Bool {
        return self.code == CKError.Code.zoneBusy ||
            self.code == CKError.Code.serviceUnavailable ||
            self.code == CKError.Code.requestRateLimited
    }
}

class CloudKitManager {
    
    enum RecordType: CodingKey, CustomStringConvertible {
        case Account
        case Subscription
        
        static func isSubscription(recordType: CKRecord.RecordType) -> Bool {
            return recordType == Subscription.stringValue
        }
    }
    
    typealias CreateOrUpdateCompletion = (_ record: CKRecord?, _ error: Error?) -> Void
    typealias Creator = (_ database: CKDatabase, _ completion: @escaping CreateOrUpdateCompletion) -> Swift.Void
    typealias UpdateEvent = (_ record: CKRecord) -> Swift.Void
    
    public static let CreateOrUpdateCompletionIgnore: CloudKitManager.CreateOrUpdateCompletion = { record, error in
        
    }

    static let shared: CloudKitManager = CloudKitManager()
    
    let container = CKContainer(identifier: "iCloud.io.windmill.windmill.macos")
    lazy var database = container.privateCloudDatabase

    func createOrUpdate(query: CKQuery, inZoneWith zoneID: CKRecordZone.ID = CKRecordZone.ID(zoneName: "Windmill", ownerName: CKCurrentUserDefaultName), create: @escaping Creator, onUpdate update: @escaping UpdateEvent, completion: @escaping CreateOrUpdateCompletion = CreateOrUpdateCompletionIgnore) {
        
        self.database.perform(query, inZoneWith: zoneID) { records, error in

            switch(records, error) {
            case(_, let error?):
                os_log("Error while querying for record in zone: '%{public}@'. Callback to create one.", log: .default, type: .debug, error.localizedDescription)
                create(self.database, completion)
            case (let records?, _) where records.isEmpty:
                os_log("No records found. Callback to create one.", log: .default, type: .debug)
                create(self.database, completion)
            case (let records?, _):
                
                guard records.count == 1, let record = records.first else {
                    os_log("More than a single records was found for query '%{public}@'.", log: .default, type: .error, query.debugDescription)
                    completion(nil, nil) //CloudKitManagerError for multiple records
                    return
                }
                
                os_log("Found record, will try to update.", log: .default, type: .debug, record)

                update(record)
                
                self.database.save(record, completionHandler: { record, error in
                    switch (record, error) {
                    case (_, let error?):
                        os_log("Error while updating record", log: .default, type: .error, error.localizedDescription)
                        completion(nil, error)
                    case (let record?, _):
                        os_log("Succesfuly updated record", log: .default, type: .debug, record)
                        completion(record, nil)
                    case (.none, .none):
                        preconditionFailure("CKDatabase.save must call with either a record or an error")
                    }
                })
            case (.none, .none):
                preconditionFailure("CKDatabase.perform must call with either a list of records or an error")
            }
        }
    }

    
    func publish(account: Account, claim: SubscriptionClaim) {
        
        guard let jwt = try? JWT.jws(jwt: claim.value), let claims = try? Claims<SubscriptionClaim>.subscription(jwt: jwt), let identifier = claims.sub else {
            return
        }
        
        let predicate = NSPredicate(format: "identifier = '\(identifier)'")
        let query = CKQuery(recordType: "Subscription", predicate: predicate)
        
        let create = { (database: CKDatabase, completion: @escaping CreateOrUpdateCompletion) in
            
            let recordZone = CKRecordZone(zoneName: "Windmill")
            let modifyRecordZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone])

            let accountRecord = CKRecord(recordType: RecordType.Account.stringValue, recordID: CKRecord.ID(zoneID: recordZone.zoneID))
            accountRecord["identifier"] = account.identifier
            
            let subscriptionRecord = CKRecord(recordType: RecordType.Subscription.stringValue, recordID: CKRecord.ID(zoneID: recordZone.zoneID))
            subscriptionRecord["identifier"] = identifier
            subscriptionRecord["claim"] = claim.value
            subscriptionRecord["account"] = CKRecord.Reference(record: accountRecord, action: .none)
            subscriptionRecord.parent = CKRecord.Reference(record: accountRecord, action: .none)
            
            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [accountRecord, subscriptionRecord], recordIDsToDelete: nil)
            modifyRecordsOperation.addDependency(modifyRecordZonesOperation)
            
            modifyRecordsOperation.savePolicy = .changedKeys
            modifyRecordsOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
                
                let record: CKRecord? = records?.first(where: { RecordType.isSubscription(recordType: $0.recordType) })
                
                switch error {
                case let error as CKError where error.isRetryServerError():
                    os_log("Error creating zone: '%{public}@'; Will retry.", log: .default, type: .debug, error.localizedDescription)
                case let error as CKError where error.isFatalServerError():
                    os_log("Fatal Error creating zone: '%{public}@'.", log: .default, type: .error, error.localizedDescription)
                default:
                    break
                }
                
                completion(record, error)
            }
            modifyRecordsOperation.qualityOfService = .utility
            database.add(modifyRecordZonesOperation)
            database.add(modifyRecordsOperation)
        }
        
        let update = { (record: CKRecord) in
            record["claim"] = claim.value
        }
        
        self.createOrUpdate(query: query, create: create, onUpdate: update)
    }
}
