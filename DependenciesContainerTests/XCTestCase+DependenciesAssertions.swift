//
//  XCTestCase+DependenciesAssertions.swift
//  DependenciesContainerTests
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import XCTest
@testable import DependenciesContainer

extension XCTestCase {

    func XCTAssertDependencyPresent<T>(_ type: T.Type, in dependenciesContainer: DependenciesContainer, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNoThrow(try dependenciesContainer.resolve(type), file: file, line: line)
    }
    
    func XCTAssertDependencyPresent<T>(_ type: T.Type, key: String, in dependenciesContainer: DependenciesContainer, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNoThrow(try dependenciesContainer.resolve(type, key: key), file: file, line: line)
    }

    func XCTAssertDependencyMissing<T>(_ type: T.Type, in dependenciesContainer: DependenciesContainer, file: StaticString = #file, line: UInt = #line) {
        XCTAssertDependencyMissing(type, key: String(reflecting: type), in: dependenciesContainer, file: file, line: line)
    }
    
    func XCTAssertDependencyMissing<T>(_ type: T.Type, key: String, in dependenciesContainer: DependenciesContainer, file: StaticString = #file, line: UInt = #line) {
        
        let expression = {
            try dependenciesContainer.resolve(DummyType.self, key: key)
        }
        
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard let dependencyError = error as? DependencyError,
                case .missing = dependencyError else {
                XCTFail("Expected `DependencyError.missing` but got `\(String(reflecting: error))` instead.", file: file, line: line)
                return
            }
            let expectedDescription = "Error attempting to `resolve` dependency for key '\(key)', but no dependency has been registered.  Perhaps you forgot to call `register`?"
            XCTAssertEqual(dependencyError.description, expectedDescription, file: file, line: line)
        }
        
    }
    
}
