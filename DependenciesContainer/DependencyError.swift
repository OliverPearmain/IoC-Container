//
//  DependencyError.swift
//  DependenciesContainer
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import Foundation

public enum DependencyError: Error, CustomStringConvertible {
    
    case missing(key: String, type: String)
    case typeMismatch(key: String, type: String)
    
    public var description: String {
        
        switch self {
            
        case let .missing(key, _):
            return "Error attempting to `resolve` dependency for key '\(key)', but no dependency has been registered.  Perhaps you forgot to call `register`?"
            
        case let .typeMismatch(key, type):
            return "Error attempting to `resolve` dependency for key '\(key)', the type registered did not match the type expected (`\(type)`).  Please check your call to `register` against your call to `resolve` to ensure the types match."
        }
    }
}
