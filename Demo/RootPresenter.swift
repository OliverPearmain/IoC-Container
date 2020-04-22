//
//  Types.swift
//  Demo
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import Foundation

protocol RootPresenter {
    var rootViewModel: RootViewModel { get }
    func refreshButtonTapped()
}

protocol HasRootPresenter {
    var rootPresenter: RootPresenter { get }
}

protocol RootPresenterDelegate: AnyObject {
    func rootPresenter(_ rootPresenter: RootPresenter, didUpdateRootViewModel rootViewModel: RootViewModel)
}

class ConcreteRootPresenter: RootPresenter {

    weak var delegate: RootPresenterDelegate?
    
    typealias Dependencies = HasStore
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.rootViewModel = Self.makeRootViewModel(fromStore: dependencies.store)
    }
    
    // MARK: RootPresenter
    
    private(set) var rootViewModel: RootViewModel {
        didSet {
            delegate?.rootPresenter(self, didUpdateRootViewModel: rootViewModel)
        }
    }
    
    func refreshButtonTapped() {
        rootViewModel = Self.makeRootViewModel(fromStore: dependencies.store)
    }
    
    // MARK: Private static
        
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }

    private static func makeRootViewModel(fromStore store: Store) -> RootViewModel {
        return RootViewModel(
            dateInstanciated: dateFormatter.string(from: store.dateInstanciated),
            dateNow: dateFormatter.string(from: store.dateNow)
        )
    }
    
}
