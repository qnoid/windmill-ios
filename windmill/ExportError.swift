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
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .incompatible(let target):
            return "This application requires iOS \(target) or later."
        case .expired:
            return "The distribution certificate used to export this application has expired.\n"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .incompatible:
            return nil
        case .expired:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .incompatible(let target):
            return "You must update this device to iOS \(target) in order to download and use this application."
        case .expired:
            return "Use Windmill on the Mac to distribute the application with an up-to-date certificate."
        }
    }
}
