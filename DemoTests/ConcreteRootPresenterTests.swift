//
//  ConcreteRootPresenterTests.swift
//  DemoTests
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import XCTest
@testable import Demo

// Demonstates how to mock/stub dependencies...

class RootPresenterTests: XCTestCase {

    private class Dependencies: HasStore {

        let store: Store

        init(store: Store) {
            self.store = store
        }
    }

    private class StubStore: Store {
        
        let dateInstanciated: Date
        let dateNow: Date
        
        init(dateInstanciated: Date, dateNow: Date) {
            self.dateInstanciated = dateInstanciated
            self.dateNow = dateNow
        }
    }
    
    private func date(fromString dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dateString)!
    }

    func test_rootViewModel_usesStoreToPopulate() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(dateInstanciated: date(fromString: "2020-01-01 09:00:00"),
                                  dateNow: date(fromString: "2020-01-02 12:30:00"))

        let dependencies = Dependencies(store: stubStore)

        let sut = ConcreteRootPresenter(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let rootViewModel = sut.rootViewModel
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(rootViewModel.dateInstanciated, "Jan 1, 2020 at 9:00:00 AM")
        XCTAssertEqual(rootViewModel.dateNow, "Jan 2, 2020 at 12:30:00 PM")
    }

}
