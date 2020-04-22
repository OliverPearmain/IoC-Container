//
//  DependenciesContainerAdvancedTests.swift
//  DependenciesContainerTests
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import XCTest
@testable import DependenciesContainer

class DependenciesContainerAdvancedTests: XCTestCase {
    
    // MARK: Circular dependencies of different types

    private class Parent {
        weak var grandchild: Grandchild?
        let child: Child
        init(child: Child) {
            self.child = child
        }
    }
    
    private class Child {
        weak var parent: Parent?
        let grandchild: Grandchild
        init(grandchild: Grandchild) {
            self.grandchild = grandchild
        }
    }
    
    private class Grandchild {
        weak var child: Child?
    }
    
    private func makeCircularDependenciesOfDifferentTypes() -> DependenciesContainer {
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(Parent.self, constructor: { dc in
            let child = try dc.resolve(Child.self)
            return Parent(child: child)
        }, postConstruction: { dc in
            let parent = try dc.resolve(Parent.self)
            parent.grandchild = try dc.resolve(Grandchild.self)
        })
        
        dependenciesContainer.register(Child.self, constructor: { dc in
            let grandchild = try dc.resolve(Grandchild.self)
            return Child(grandchild: grandchild)
        }, postConstruction: { dc in
            let child = try dc.resolve(Child.self)
            child.parent = try dc.resolve(Parent.self)
        })
        
        dependenciesContainer.register(Grandchild.self, constructor: { _ in
            Grandchild()
        }, postConstruction: { dc in
            let grandchild = try dc.resolve(Grandchild.self)
            grandchild.child = try dc.resolve(Child.self)
        })
        
        return dependenciesContainer
    }
    
    private func XCTAssertCircularDependenciesOfDifferentTypes(parent: Parent?, child: Child?, grandchild: Grandchild?, file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertNotNil(parent, file: file, line: line)
        XCTAssertNotNil(child, file: file, line: line)
        XCTAssertNotNil(grandchild, file: file, line: line)
        
        XCTAssertTrue(parent?.grandchild === grandchild, file: file, line: line)
        XCTAssertTrue(parent?.child === child, file: file, line: line)
        XCTAssertTrue(child?.parent === parent, file: file, line: line)
        XCTAssertTrue(child?.grandchild === grandchild, file: file, line: line)
        XCTAssertTrue(grandchild?.child === child, file: file, line: line)
    }
    
    func test_givenCircularDependenciesOfDifferentTypes_whenResolvingInOrderA_thenSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfDifferentTypes()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // NOTE the order of these calls is imperative
        let parent = try? dependenciesContainer.resolve(Parent.self)
        let child = try? dependenciesContainer.resolve(Child.self)
        let grandchild = try? dependenciesContainer.resolve(Grandchild.self)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfDifferentTypes(parent: parent, child: child, grandchild: grandchild)
    }

    func test_givenCircularDependenciesOfDifferentTypes_whenResolvingInOrderB_thenSuccess() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfDifferentTypes()

        /******************/
        /*----- WHEN -----*/
        /******************/

        let grandchild = try? dependenciesContainer.resolve(Grandchild.self)
        let child = try? dependenciesContainer.resolve(Child.self)
        let parent = try? dependenciesContainer.resolve(Parent.self)

        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfDifferentTypes(parent: parent, child: child, grandchild: grandchild)
    }

    func test_givenCircularDependenciesOfDifferentTypes_whenResolvingInOrderC_thenSuccess() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfDifferentTypes()

        /******************/
        /*----- WHEN -----*/
        /******************/

        // NOTE the order of these calls is important
        let child = try? dependenciesContainer.resolve(Child.self)
        let parent = try? dependenciesContainer.resolve(Parent.self)
        let grandchild = try? dependenciesContainer.resolve(Grandchild.self)

        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfDifferentTypes(parent: parent, child: child, grandchild: grandchild)
    }

    // MARK: Circular dependenencies of same type with custom keys
    
    private class Person {
        weak var parent: Person?
        
        let children: [Person]
        
        init(children: [Person] = []) {
            self.children = children
        }
    }
    
    private enum Names: String {
        case elizabethElizabeth = "Quene Elizabeth"
        case princeCharles = "Prince Charles"
        case princeWilliam = "Prince William"
        case princeHarry = "Prince Harry"
    }
    
    private func makeCircularDependenciesOfSameTypeWithCustomKeys() -> DependenciesContainer {
        
        let dependenciesContainer = DependenciesContainer()
        
        dependenciesContainer.register(Person.self, key: Names.elizabethElizabeth.rawValue, constructor: { dc in
            let charles = try dc.resolve(Person.self, key: Names.princeCharles.rawValue)
            return Person(children: [charles])
        })
        
        dependenciesContainer.register(Person.self, key: Names.princeCharles.rawValue, constructor: { dc in
            let william = try dc.resolve(Person.self, key: Names.princeWilliam.rawValue)
            let harry = try dc.resolve(Person.self, key: Names.princeHarry.rawValue)
            return Person(children: [william, harry])
        }, postConstruction: { dc in
            let charles = try dc.resolve(Person.self, key: Names.princeCharles.rawValue)
            charles.parent = try dc.resolve(Person.self, key: Names.elizabethElizabeth.rawValue)
        })
        
        dependenciesContainer.register(Person.self, key: Names.princeWilliam.rawValue, constructor: { _ in
            Person()
        }, postConstruction: { dc in
            let william = try dc.resolve(Person.self, key: Names.princeWilliam.rawValue)
            william.parent = try dc.resolve(Person.self, key: Names.princeCharles.rawValue)
        })
        
        dependenciesContainer.register(Person.self, key: Names.princeHarry.rawValue, constructor: { _ in
            Person()
        }, postConstruction: { dc in
            let harry = try dc.resolve(Person.self, key: Names.princeHarry.rawValue)
            harry.parent = try dc.resolve(Person.self, key: Names.princeCharles.rawValue)
        })
        
        return dependenciesContainer
    }
    
    private func XCTAssertCircularDependenciesOfSameTypeWithCustomKeys(elizabeth: Person?, charles: Person?, william: Person?, harry: Person?, file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertNotNil(elizabeth, file: file, line: line)
        XCTAssertNotNil(charles, file: file, line: line)
        XCTAssertNotNil(william, file: file, line: line)
        XCTAssertNotNil(harry, file: file, line: line)
        
        XCTAssertNil(elizabeth?.parent, file: file, line: line)
        XCTAssertEqual(elizabeth?.children.count, 1, file: file, line: line)
        XCTAssertTrue(elizabeth?.children[0] === charles, file: file, line: line)
        
        XCTAssertTrue(charles?.parent === elizabeth, file: file, line: line)
        XCTAssertEqual(charles?.children.count, 2, file: file, line: line)
        XCTAssertTrue(charles?.children[0] === william, file: file, line: line)
        XCTAssertTrue(charles?.children[1] === harry, file: file, line: line)
        
        XCTAssertTrue(william?.parent === charles, file: file, line: line)
        XCTAssertEqual(william?.children.count, 0, file: file, line: line)
        
        XCTAssertTrue(harry?.parent === charles, file: file, line: line)
        XCTAssertEqual(harry?.children.count, 0, file: file, line: line)
    }
    
    func test_givenCircularDependenciesOfSameTypeWithCustomKeys_whenResolvingInOrderA_thenSuccess() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfSameTypeWithCustomKeys()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let elizabeth = try? dependenciesContainer.resolve(Person.self, key: Names.elizabethElizabeth.rawValue)
        let charles = try? dependenciesContainer.resolve(Person.self, key: Names.princeCharles.rawValue)
        let william = try? dependenciesContainer.resolve(Person.self, key: Names.princeWilliam.rawValue)
        let harry = try? dependenciesContainer.resolve(Person.self, key: Names.princeHarry.rawValue)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfSameTypeWithCustomKeys(elizabeth: elizabeth, charles: charles, william: william, harry: harry)
    }
    
    func test_givenCircularDependenciesOfSameTypeWithCustomKeys_whenResolvingInOrderB_thenSuccess() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfSameTypeWithCustomKeys()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let harry = try? dependenciesContainer.resolve(Person.self, key: Names.princeHarry.rawValue)
        let william = try? dependenciesContainer.resolve(Person.self, key: Names.princeWilliam.rawValue)
        let charles = try? dependenciesContainer.resolve(Person.self, key: Names.princeCharles.rawValue)
        let elizabeth = try? dependenciesContainer.resolve(Person.self, key: Names.elizabethElizabeth.rawValue)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfSameTypeWithCustomKeys(elizabeth: elizabeth, charles: charles, william: william, harry: harry)
    }
    
    func test_givenCircularDependenciesOfSameTypeWithCustomKeys_whenResolvingInOrderC_thenSuccess() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependenciesContainer = makeCircularDependenciesOfSameTypeWithCustomKeys()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let william = try? dependenciesContainer.resolve(Person.self, key: Names.princeWilliam.rawValue)
        let elizabeth = try? dependenciesContainer.resolve(Person.self, key: Names.elizabethElizabeth.rawValue)
        let harry = try? dependenciesContainer.resolve(Person.self, key: Names.princeHarry.rawValue)
        let charles = try? dependenciesContainer.resolve(Person.self, key: Names.princeCharles.rawValue)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertCircularDependenciesOfSameTypeWithCustomKeys(elizabeth: elizabeth, charles: charles, william: william, harry: harry)
    }

}
