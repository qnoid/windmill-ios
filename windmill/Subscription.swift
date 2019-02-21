//
//  SubscriptionError.swift
//  windmill
//
//  Created by Markos Charatzas on 07/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public enum SubscriptionError : Error {
    case failed
    case connectionError(error: URLError)
    case restoreFailed
    case restoreConnectionError(error: URLError)
}

extension SubscriptionError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorTitle: String? {
        switch self {
        case .failed:
            return "Your purchase was succesful"
        case .connectionError:
            return "Your purchase was succesful"
        case .restoreFailed:
            return "Restore Purchases Failed"
        case .restoreConnectionError:
            return "Restore Purchases Failed"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .failed:
            return "There was an unexpected error while buying/renewing your subscription.\n\n"
        case .connectionError:
            return nil
        case .restoreFailed:
            return "There was an unexpected error while restoring your subscription."
        case .restoreConnectionError:
            return nil
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .failed:
            return nil
        case .connectionError:
            return "Buying/renewing your subscription failed because of a network error.\n\n"
        case .restoreFailed:
            return nil
        case .restoreConnectionError:
            return "Restoring your subscription failed because of a network error."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failed:
            return "Windmill will try again sometime later.\nOptionally, you can contact qnoid@windmill.io"
        case .connectionError:
            return "Windmill will try again sometime later."
        case .restoreFailed:
            return "You can try again some time later or contact qnoid@windmill.io."
        case .restoreConnectionError:
            return nil
        }
    }
}
