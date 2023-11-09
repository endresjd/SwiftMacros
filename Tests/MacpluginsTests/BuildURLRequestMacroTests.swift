//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  BuildURLRequestMacroTests.swift
//
//
//  Created by John Endres on 10/31/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacpluginsMacrosCore)
import MacpluginsMacrosCore
#endif

final class BuildURLRequestMacroTests: XCTestCase {
    
    func testNameCollision() throws {
        assertMacroExpansion(
            """
            let url = "https://www.apple.com"
            let result = #buildURLRequest(url)
            """,
            expandedSource: """
            let url = "https://www.apple.com"
            let result = {
                guard let url = URL(string: url) else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers: [String: String] = [:]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
    
    func testVariableValue() throws {
        assertMacroExpansion(
            """
            let value = "https://www.apple.com"
            let result = #buildURLRequest(value)
            """,
            expandedSource: """
            let value = "https://www.apple.com"
            let result = {
                guard let url = URL(string: value) else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers: [String: String] = [:]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
    
    func testEmptyString() throws {
        assertMacroExpansion(
            """
            let result = #buildURLRequest("")
            """,
            expandedSource: """
            let result = nil as URLRequest?
            """,
            diagnostics: [
                DiagnosticSpec(message: "Value for URL is invalid", line: 1, column: 14)
            ],
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
    
    func testSimpleGet() throws {
        assertMacroExpansion(
            """
            let result = #buildURLRequest("https://www.apple.com")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers: [String: String] = [:]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
    
    func testExplicitGet() throws {
        assertMacroExpansion(
            """
            let result = #buildURLRequest("https://www.apple.com", method: "GET")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers: [String: String] = [:]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
    
    func testAllParameters() throws {
        assertMacroExpansion(
            """
            let result = #buildURLRequest("https://www.apple.com", method: "PUT", headers: ["one":"two", "three":"four"])
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "PUT"
                let headers: [String: String] = ["one": "two", "three": "four"]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }

    func testSimplePut() throws {
        assertMacroExpansion(
            """
            let result = #buildURLRequest("https://www.apple.com", method: "PUT")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "PUT"
                let headers: [String: String] = [:]
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["buildURLRequest": BuildURLRequestMacro.self]
        )
    }
}
