//
//  EquatableMacroTests.swift
//
//
//  Created by Endres, John on 8/5/24.
//
 
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
 
#if canImport(MacpluginsMacrosCore)
import MacpluginsMacrosCore
#endif

final class EquatableMacroTests: XCTestCase {
 
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
 
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
 
    func testEquatable() throws {
#if canImport(MacpluginsMacrosCore)
        assertMacroExpansion(
            """
            @Equatable
            class XXX {}
            """,
            expandedSource: """
            class XXX {}
            
            extension XXX: Equatable {
            }
            """,
            macros: ["Equatable": EquatableMacro.self]
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
 
}

