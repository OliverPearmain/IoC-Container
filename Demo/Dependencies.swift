//
//  Dependencies.swift
//  Demo
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import Foundation
import DependenciesContainer

protocol Dependencies:
    HasRootViewController &
    HasRootPresenter &
    HasStore
{}

class ConcreteDependencies: Dependencies {
    
    private let dependenciesContainer = DependenciesContainer()
    
    init() {
        
        dependenciesContainer.register(RootViewController.self) { _ in
            RootViewController(dependencies: self)
        }
        
        dependenciesContainer.register(RootPresenter.self, constructor: { _ in
            ConcreteRootPresenter(dependencies: self)
        }, postConstruction: { _ in
            let rootPresenter = self.rootPresenter as! ConcreteRootPresenter
            rootPresenter.delegate = self.rootViewController
        })
        
        dependenciesContainer.register(Store.self) { _ in
            ConcreteStore()
        }
    }
    
    var rootViewController: RootViewController {
        return try! dependenciesContainer.resolve(RootViewController.self)
    }

    var rootPresenter: RootPresenter {
        return try! dependenciesContainer.resolve(RootPresenter.self)
    }
    
    var store: Store {
        return try! dependenciesContainer.resolve(Store.self)
    }

}
