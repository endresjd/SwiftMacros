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
    
    func testUnquotedSubsystem() throws {
        assertMacroExpansion(
            """
            @OSLogger(subsystem: Bundle.main.bundleIdentifier!)
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            
                private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Foo")
            }
            """,
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testBundleDefault() throws {
        assertMacroExpansion(
            """
            @OSLogger
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {
            
                private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Unknown", category: "Foo")
            }
            """,
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testLearning() throws {
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
                DiagnosticSpec(message: "Unspupported value for subsystem", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
    
    func testVariableExpansion() throws {
        assertMacroExpansion(
            """
            let loggerName = "loggerNameVal"
            let subsystem = "subsystemVal"
            let category = "categoryVal"
            
            @OSLogger(loggerName, subsystem: subsystem, category: category)
            class Foo {
            }
            """,
            expandedSource: """
            let loggerName = "loggerNameVal"
            let subsystem = "subsystemVal"
            let category = "categoryVal"
            class Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "loggerName must be a non-empty quoted string", line: 5, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )

        assertMacroExpansion(
            """
            let subsystem = "subsystemVal"
            let category = "categoryVal"
            
            @OSLogger("loggerName", subsystem: subsystem, category: category)
            class Foo {
            }
            """,
            expandedSource: """
            let subsystem = "subsystemVal"
            let category = "categoryVal"
            class Foo {
            
                private let loggerName = Logger(subsystem: subsystem, category: category)
            }
            """,
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

                private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Unknown", category: "Foo")
            }
            """,
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
                DiagnosticSpec(message: "Unspupported value for subsystem", line: 1, column: 1)
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
                DiagnosticSpec(message: "Unspupported value for category", line: 1, column: 1)
            ],
            macros: ["OSLogger": OSLoggerMacro.self]
        )
    }
}
