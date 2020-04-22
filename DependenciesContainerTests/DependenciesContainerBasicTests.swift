//
//  DependenciesContainerBasicTests.swift
//  DependenciesContainerTests
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import XCTest
@testable import DependenciesContainer

class DummyType {}

class DependenciesContainerBasicTests: XCTestCase {

    // MARK: `resolve` tests
    
    func test_resolve_withoutKey_givenDependencyRegistered_thenReturnsDependency() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(DummyType.self) { _ in
            DummyType()
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dummyType = try? dependenciesContainer.resolve(DummyType.self)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(dummyType)
        
        // Verify that a new object is not initialised on each call to `resolve`
        XCTAssertTrue(dummyType === (try? dependenciesContainer.resolve(DummyType.self)))
    }
    
    func test_resolve_withoutKey_givenMismatchedTypeDependencyRegistered_thenThrowsTypeMismatchDependencyError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        // NOTE to deliberately force a mismatch we register a "String" with custom a key of "DependenciesContainerTests.DummyType"
        let key = String(reflecting: DummyType.self)
        dependenciesContainer.register(String.self, key: key) { _ in
            "Not a \(DummyType.self)"
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expression = {
            try dependenciesContainer.resolve(DummyType.self)
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertThrowsError(try expression()) { error in
            guard let dependencyError = error as? DependencyError,
                case .typeMismatch = dependencyError else {
                    XCTFail("Expected `DependencyError.typeMismatch` but got `\(type(of: error))` instead.")
                return
            }
            let expectedDescription = "Error attempting to `resolve` dependency for key '\(String(reflecting: DummyType.self))', the type registered did not match the type expected (`\(String(reflecting: DummyType.self))`).  Please check your call to `register` against your call to `resolve` to ensure the types match."
            XCTAssertEqual(dependencyError.description, expectedDescription)
        }
    }
    
    func test_resolve_withoutKey__givenDepedencyNotRegistered_thenThrowsMissingDependencyError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expression = {
            try dependenciesContainer.resolve(DummyType.self)
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertThrowsError(try expression()) { error in
            guard let dependencyError = error as? DependencyError,
                case .missing = dependencyError else {
                    XCTFail("Expected `DependencyError.missing` but got `\(type(of: error))` instead.")
                return
            }
            let expectedDescription = "Error attempting to `resolve` dependency for key '\(String(reflecting: DummyType.self))', but no dependency has been registered.  Perhaps you forgot to call `register`?"
            XCTAssertEqual(dependencyError.description, expectedDescription)
        }
    }
    
    func test_resolve_withKey_givenDependencyRegistered_thenReturnsDependency() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        let customKey = "Custom Key"
        dependenciesContainer.register(DummyType.self, key: customKey) { _ in
            DummyType()
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dummyType = try? dependenciesContainer.resolve(DummyType.self, key: customKey)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(dummyType)
        
        // Verify that a new object is not initialised on each call to `resolve`
        XCTAssertTrue(dummyType === (try? dependenciesContainer.resolve(DummyType.self, key: customKey)))
    }
    
    func test_resolve_withKey_givenMismatchedTypeDependencyRegistered_thenThrowsTypeMismatchDependencyError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        // NOTE to deliberately force a mismatch we register a "String" with our custom a key
        let customKey = "Custom Key"
        dependenciesContainer.register(String.self, key: customKey) { _ in
            "Not a \(DummyType.self)"
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expression = {
            try dependenciesContainer.resolve(DummyType.self, key: customKey)
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertThrowsError(try expression()) { error in
            guard let dependencyError = error as? DependencyError,
                case .typeMismatch = dependencyError else {
                    XCTFail("Expected `DependencyError.typeMismatch` but got `\(type(of: error))` instead.")
                return
            }
            let expectedDescription = "Error attempting to `resolve` dependency for key '\(customKey)', the type registered did not match the type expected (`\(String(reflecting: DummyType.self))`).  Please check your call to `register` against your call to `resolve` to ensure the types match."
            XCTAssertEqual(dependencyError.description, expectedDescription)
        }
    }
    
    func test_resolve_withKey_givenDepedencyNotRegistered_thenThrowsMissingDependencyError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(DummyType.self) { _ in
            DummyType()
        }
        
        let customKey = "Custom Key"
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expression = {
            try dependenciesContainer.resolve(DummyType.self, key: customKey)
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertThrowsError(try expression()) { error in
            guard let dependencyError = error as? DependencyError,
                case .missing = dependencyError else {
                    XCTFail("Expected `DependencyError.missing` but got `\(type(of: error))` instead.")
                return
            }
            let expectedDescription = "Error attempting to `resolve` dependency for key '\(customKey)', but no dependency has been registered.  Perhaps you forgot to call `register`?"
            XCTAssertEqual(dependencyError.description, expectedDescription)
        }
    }
    
    // MARK: `deregister` tests
    
    func test_deregister_withType_givenNoDependencyRegistered_thenNoDependencyRegistered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        XCTAssertDependencyMissing(DummyType.self, in: dependenciesContainer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        dependenciesContainer.deregister(DummyType.self)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertDependencyMissing(DummyType.self, in: dependenciesContainer)
    }
        
    func test_deregister_withType__givenDependencyRegistered_thenNoDependencyRegistered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(DummyType.self) { _ in
            DummyType()
        }
        
        XCTAssertDependencyPresent(DummyType.self, in: dependenciesContainer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        dependenciesContainer.deregister(DummyType.self)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertDependencyMissing(DummyType.self, in: dependenciesContainer)
    }
    
    func test_deregister_withKey_givenNoDependencyRegistered_thenNoDependencyRegistered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        XCTAssertDependencyMissing(DummyType.self, in: dependenciesContainer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        dependenciesContainer.deregister(key: "Custom Key")
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertDependencyMissing(DummyType.self, in: dependenciesContainer)
    }
        
    func test_deregister_withKey__givenDependencyRegistered_thenNoDependencyRegistered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(DummyType.self, key: "Custom Key") { _ in
            DummyType()
        }
        
        XCTAssertDependencyPresent(DummyType.self, key: "Custom Key", in: dependenciesContainer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        dependenciesContainer.deregister(key: "Custom Key")
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertDependencyMissing(DummyType.self, key: "Custom Key", in: dependenciesContainer)
    }
}
