//
//  SubscriptionError.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 07/02/2019.
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

public enum SubscriptionError : Error {
    
    case failed
    case connectionError(error: URLError)
    case restoreFailed
    case restoreConnectionError(error: URLError)
    
    public enum UnauthorisationReason: String {
        case expired
        
        var key: String {
            switch self {
            case .expired:
                return "subscription.expired"
            }
        }
    }
    
    case unauthorised(reason: UnauthorisationReason?)
    case outdated
    case expired
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
            return "Restore Failed"
        case .restoreConnectionError:
            return "Restore Failed"
        case .unauthorised(let reason):
            switch reason {
            case (.expired?):
                return "Subscription Expired"
            default:
                return "Subscription Access"
            }
        case .expired:
            return "Subscription Expired"
        case .outdated:
            return "Outdated Receipt"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .failed:
            return "There was an unexpected error while buying/renewing your subscription.\n\n"
        case .connectionError:
            return nil
        case .restoreFailed:
            return "There was an unexpected error while restoring your subscription.\n"
        case .restoreConnectionError:
            return nil
        case .unauthorised(let reason):
            if let reason = reason {
                return NSLocalizedString("\(SubscriptionError.errorDomain).\(reason.key)", comment: "Your subscription has expired or may have not renewed just yet.\n")
            }
            else {
                return "Your Windmill subscription is no longer active.\n"
            }
        case .expired:
            return NSLocalizedString("\(SubscriptionError.errorDomain).\(UnauthorisationReason.expired.key)", comment: "Your subscription has expired or may have not renewed just yet.\n")
        case .outdated:
            return NSLocalizedString("\(SubscriptionError.errorDomain).subscription.outdated", comment: "Your purchase receipt has not recorded any payment transactions yet.\n")
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
        case .unauthorised:
            return nil
        case .expired:
            return nil
        case .outdated:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failed:
            return "Windmill will try again sometime later.\nOptionally, you can contact qnoid@windmill.io"
        case .connectionError:
            return "Windmill will try again sometime later.\nOptionally, under your Account, you can choose to Refresh the Subscription now."
        case .restoreFailed:
            return "You can try again some time later or contact qnoid@windmill.io."
        case .restoreConnectionError:
            return nil
        case .unauthorised(let reason):
            switch reason {
            case (.expired?):
                return "In the latter case, Windmill will try again sometime later. Optionally, you can choose to Refresh the Subscription now."
            default:
                return "You can purchase a new subscription or contact qnoid@windmill.io"
            }
        case .expired:
            return "In the latter case, Windmill will try again sometime later. Optionally, you can choose to Refresh the Subscription now."
        case .outdated:
            return "Windmill will try again sometime later. Optionally, you can choose to Refresh the Receipt now."
        }
    }
    
    public var isUnauthorised: Bool {
        switch self {
        case .unauthorised:
            return true
        default:
            return false
        }
    }
    
    public var isExpired: Bool {
        switch self {
        case .unauthorised(let reason?):
            return reason == .expired
        case .expired:
            return true
        default:
            return false
        }
    }
    
    public var isOutdated: Bool {
        switch self {
        case .outdated:
            return true
        default:
            return false
        }
    }

}
