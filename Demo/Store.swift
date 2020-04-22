//
//  Store.swift
//  Demo
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import Foundation

protocol Store {
    var dateInstanciated: Date { get }
    var dateNow: Date { get }
}

protocol HasStore {
    var store: Store { get }
}

class ConcreteStore: Store {
    
    let dateInstanciated = Date()
    
    var dateNow: Date {
        Date()
    }
}
