//
//  DependenciesContainer.swift
//  DependenciesContainer
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import Foundation

public class DependenciesContainer {
    
    // MARK: - Types
    
    private enum DependencyState<T> {
        case registered(Constructor<T>, PostConstruction?)
        case initialised(T)
    }
    
    // MARK: - Private members
    
    private var dependencyStates = [String: Any]()
    private var nestedResolveCallCount = 0
    private var postConstructionQueue = [PostConstruction]()
    
    // MARK: - Public
    
    public typealias Constructor<T> = (DependenciesContainer) throws -> T
    public typealias PostConstruction = (DependenciesContainer) throws -> Void
    
    public init() {}
    
    public func register<T>(_ type: T.Type, key: String? = nil, constructor: @escaping Constructor<T>) {
        register(type, key: key, constructor: constructor, postConstruction: nil)
    }
    
    public func register<T>(_ type: T.Type, key: String? = nil, constructor: @escaping Constructor<T>, postConstruction: PostConstruction?) {
        dependencyStates[key ?? self.key(type)] = DependencyState<T>.registered(constructor, postConstruction)
    }
    
    public func deregister<T>(_ type: T.Type) {
        deregister(key: key(type))
    }
    
    public func deregister(key: String) {
        dependencyStates[key] = nil
    }
    
    public func resolve<T>(_ type: T.Type) throws -> T {
        return try resolve(type, key: key(type))
    }
    
    public func resolve<T>(_ type: T.Type, key: String) throws -> T {
        
        guard dependencyStates[key] != nil else {
            throw DependencyError.missing(key: key, type: String(reflecting: type))
        }
        
        guard let dependencyState = dependencyStates[key] as? DependencyState<T> else {
            throw DependencyError.typeMismatch(key: key, type: String(reflecting: type))
        }
        
        switch dependencyState {
            
        case let .registered(constructor, postConstruction):
            
            // Keep a count of "nested `resolve` calls"
            // Why? If a `constructor` itself invokes a call (or calls) to `resolve` we
            // don't want to execute any `postConstruction` closures until all of the
            // `resolve` calls `constructor`s have completed.
            // This ensures that dependencies don't get created more than once when we
            // have circular dependencies.
            nestedResolveCallCount += 1

            // We use `do`and `defer` to ensure we decrement `nestedResolveCallCount` even if the
            // call to `constructor()` throws
            let dependency: T
            do {
                defer {
                    nestedResolveCallCount -= 1
                }
                dependency = try constructor(self)
                dependencyStates[key] = DependencyState<T>.initialised(dependency)
            }
            
            // If a `postConsruction` closure was defined for this dependency add it to the queue
            if let postConstruction = postConstruction {
                postConstructionQueue.append(postConstruction)
            }
            
            // Determine if we need to process the `postConstructionQueue`
            // We only process the queue once all nested `resolve` calls have been completed
            if nestedResolveCallCount == 0 {
                for postConstructionQueue in postConstructionQueue {
                    try postConstructionQueue(self)
                }
                postConstructionQueue.removeAll()
            }
            
            return dependency
            
        case let .initialised(dependency):
            return dependency
            
        }
    }
    
    // MARK: - Private
    
    private func key<T>(_ type: T.Type) -> String {
        return String(reflecting: type)
    }
}
