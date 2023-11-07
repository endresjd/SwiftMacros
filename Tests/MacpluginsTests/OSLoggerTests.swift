//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  OSLoggerTests.swift
//
//
//  Created by John Endres on 11/4/23.
//

import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import MacpluginsMacrosCore

final class OSLoggerTests: XCTestCase {
    
    func testWrongType() {
        assertMacroExpansion(
            """
            @OSLogger(subsystem: "Client")
            enum John {
            case one
            }
            """,
            expandedSource: 
            """
            enum John {
            case one
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "OSLogger can only be attached to class or struct", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testAllArguments() throws {
        assertMacroExpansion(
            """
            @OSLogger("variablename", subsystem: "subsystem", category: "category")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            
                private let variablename = Logger(subsystem: "subsystem", category: "category")
            }
            """,
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testOnlyVariableName() throws {
        assertMacroExpansion(
            """
            @OSLogger("variablename", subsystem: "Macplugins")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            
                private let variablename = Logger(subsystem: "Macplugins", category: "Foo")
            }
            """,
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testDefault() throws {
        assertMacroExpansion(
            """
            @OSLogger(subsystem: "Macplugins")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            
                private let logger = Logger(subsystem: "Macplugins", category: "Foo")
            }
            """,
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testUnquotedValues() throws {
        assertMacroExpansion(
            """
            @OSLogger(subsystem: Bundle.main.bundleIdentifier!)
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "subsystem must be a non-empty quoted string", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testEmpty() throws {
        assertMacroExpansion(
            """
            @OSLogger("")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "loggerName must be a non-empty quoted string", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )

        assertMacroExpansion(
            """
            @OSLogger
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "subsystem must be a non-empty quoted string", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )

        assertMacroExpansion(
            """
            @OSLogger(subsystem: "")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "subsystem must be a non-empty quoted string", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )

        assertMacroExpansion(
            """
            @OSLogger(subsystem: "Client", category: "")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "category must be a non-empty quoted string", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
}
