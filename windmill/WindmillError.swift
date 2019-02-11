//
//  WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas on 07/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public enum WindmillError : Error {
    case subscriptionFailed
    case subscriptionConnectionError(error: URLError)
    case restorePurchasesFailed
    case restorePurchasesConnectionError(error: URLError)
}

extension WindmillError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorTitle: String? {
        switch self {
        case .subscriptionFailed:
            return "Your purchase was succesful"
        case .subscriptionConnectionError:
            return "Your purchase was succesful"
        case .restorePurchasesFailed:
            return "Restore Purchases Failed"
        case .restorePurchasesConnectionError:
            return "Restore Purchases Failed"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .subscriptionFailed:
            return "There was an unexpected error while renewing your subscription.\n\n"
        case .subscriptionConnectionError:
            return nil
        case .restorePurchasesFailed:
            return "There was an unexpected error while restoring your subscription."
        case .restorePurchasesConnectionError:
            return nil
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .subscriptionFailed:
            return nil
        case .subscriptionConnectionError:
            return "Renewing your subscription failed because of a network error.\n\n"
        case .restorePurchasesFailed:
            return nil
        case .restorePurchasesConnectionError:
            return "Restoring your subscription failed because of a network error."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .subscriptionFailed:
            return "Windmill will try again sometime later.\nOptionally, you can contact qnoid@windmill.io"
        case .subscriptionConnectionError:
            return "Windmill will try again sometime later."
        case .restorePurchasesFailed:
            return "You can try again some time later or contact qnoid@windmill.io."
        case .restorePurchasesConnectionError:
            return nil
        }
    }
}
