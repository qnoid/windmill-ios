//
//  ExportError.swift
//  windmill
//
//  Created by Markos Charatzas on 24/04/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import Foundation

public enum ExportError : Error {
    
    case incompatible(target: String)
    case expired
    case elapsed
}

extension ExportError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorTitle: String? {
        switch self {
        case .incompatible:
            return "Unsupported iOS"
        case .expired:
            return "Distribution Certificated Expired"
        case .elapsed:
            return "Access Elapsed"
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .incompatible(let target):
            return "This application requires iOS \(target) or later."
        case .expired:
            return "The distribution certificate used to export this application has expired.\n"
        case .elapsed:
            return "Access to this application has elapsed.\n"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .incompatible:
            return nil
        case .expired:
            return nil
        case .elapsed:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .incompatible(let target):
            return "You must update this device to iOS \(target) in order to download and use this application."
        case .expired:
            return "Use Windmill on the Mac to distribute the application with an up-to-date certificate."
        case .elapsed:
            return "You can choose to Refresh your list of applications for as long as your Subscription is still active."
        }
    }
    
    public var isDenied: Bool {
        switch self {
        case .elapsed:
            return true
        default:
            return false
        }
    }
}
