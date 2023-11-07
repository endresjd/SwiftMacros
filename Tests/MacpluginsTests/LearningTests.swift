//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  LearningTests.swift
//  
//
//  Created by John Endres on 11/1/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftDiagnostics
import XCTest

private enum LearningMacroDiagnostic: String, DiagnosticMessage {
    case unknown
    case variable
    case type
    
    var severity: DiagnosticSeverity {
        switch self {
        case .unknown, .variable, .type:
            return .error
        }
    }
    
    var message: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .variable:
            return "Must be attached to an URL variable"
        case .type:
            return "Type of variable must be URL"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "MacpluginsMacros", id: rawValue)
    }
}

// The macro expansion can introduce "peer" declarations that sit alongside the given declaration.

private struct LearningMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Get the first parameter, the one with no label, the one that has the label ignored in the
        // declaration of the macro.
        guard let value = node.argumentList.first(where: { $0.label == nil })?.expression else {
            context.diagnose(Diagnostic(node: node, message: LearningMacroDiagnostic.variable))
            
            return ""
        }
        
        // First line of the code block being returned
        let urlStatement = CodeBlockItemSyntax(item: .stmt("""
            guard let url = URL(string: \(raw: value)) else {
                return nil
            }
            """)
        )

        // Create the request here after getting the URL
        let urlRequestDeclaration = CodeBlockItemSyntax(item: .decl("var result = URLRequest(url: url)"))

        // Default values for the optional macro parameters.  They don't seem to be passed
        // of, more likely, I don't see how to get them yet.
        var methodExpression = CodeBlockItemSyntax(item: .expr(#"result.httpMethod = "GET""#))
        var headersStatements = CodeBlockItemSyntax(item: .decl("let headers = [:]"))
        
        // Iterate through all the parameters with explicit names.  In this case for this macro
        // these will be the optional parameters "method" and "headers".  Replace the defaults
        // from above with real values.
        node
            .argumentList
            .filter {
                $0.label != nil
            }
            .forEach { tupleExprElementSyntax in
                if let parameter = tupleExprElementSyntax.label?.text {
                    switch parameter {
                    case "method":
                        methodExpression = CodeBlockItemSyntax(item: .expr("result.httpMethod = \(tupleExprElementSyntax.expression)"))
                    case "headers":
                        // Create an inline dictionary then iterate over it?
                        headersStatements = CodeBlockItemSyntax(item: .decl("let headers = \(tupleExprElementSyntax.expression)"))
                    default:
                        break
                    }
                }
            }

        // Block of code that assigns the header values into the request.
        let headerAssignmentStatement = CodeBlockItemSyntax(item: .stmt("""
            for (header, value) in headers {
                result.addValue(value, forHTTPHeaderField: header)
            }
            """)
        )
        let returnStatement = CodeBlockItemSyntax(item: .stmt("return result"))
        
        // Create a list of statements that will go into the block/closure in the order given.
        let statementList = CodeBlockItemListSyntax(arrayLiteral: urlStatement, urlRequestDeclaration, methodExpression, headersStatements, headerAssignmentStatement, returnStatement)
        
        // Create the closure from that statement list
        let closure = ClosureExprSyntax(statements: statementList)
        
        // Add the call () to the closure
        let function = FunctionCallExprSyntax(callee: closure)
        
        // Return the entire expression.
        return ExprSyntax(function)
        
        // More direct route example that may be prone to interpolation errors, but that may represent
        // the actual intention of how to write these.
        //return """
        //    {
        //        guard let url = URL(string: \(raw: value)) else {
        //            return nil
        //        }
        //    
        //        var result = URLRequest(url: url)
        //    
        //        result.httpMethod = "GET"
        //    
        //        return result
        //    }()
        //    """
    }
}

final class LearningTests: XCTestCase {
    
    func testSimpleGet() throws {
        assertMacroExpansion(
            """
            let result = #learning("https://www.apple.com")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers = [:]
                for (header, value) in headers {
                    result.addValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["learning": LearningMacro.self]
        )
    }
    
    func testExplicitGet() throws {
        assertMacroExpansion(
            """
            let result = #learning("https://www.apple.com", method: "GET")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "GET"
                let headers = [:]
                for (header, value) in headers {
                    result.addValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["learning": LearningMacro.self]
        )
    }
    
    func testAllParameters() throws {
        assertMacroExpansion(
            """
            let result = #learning("https://www.apple.com", method: "PUT", headers: ["one":"two", "three":"four"])
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "PUT"
                let headers = ["one": "two", "three": "four"]
                for (header, value) in headers {
                    result.addValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["learning": LearningMacro.self]
        )
    }

    func testSimplePut() throws {
        assertMacroExpansion(
            """
            let result = #learning("https://www.apple.com", method: "PUT")
            """,
            expandedSource: """
            let result = {
                guard let url = URL(string: "https://www.apple.com") else {
                    return nil
                }
                var result = URLRequest(url: url)
                result.httpMethod = "PUT"
                let headers = [:]
                for (header, value) in headers {
                    result.addValue(value, forHTTPHeaderField: header)
                }
                return result
            }()
            """,
            macros: ["learning": LearningMacro.self]
        )
    }
}
