//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  BuildURLRequestMacro.swift
//
//
//  Created by John Endres on 10/31/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// Diagnostic information for this macro.
private enum BuildURLRequestMacroDiagnostic: String, DiagnosticMessage {
    /// Raised if the macro detects no string (parameter 1) was given to it.
    case invalideURLString
    
    /// If there were problems parsing out the ethod
    case invalidMethodString
    
    /// The headers value is invalid
    case invalidHeaders
    
    /// Severity of this diagnostic
    var severity: DiagnosticSeverity {
        switch self {
        case .invalideURLString, .invalidMethodString, .invalidHeaders:
            return .error
        }
    }
    
    /// User visibile message for a given case.
    var message: String {
        switch self {
        case .invalideURLString:
            return "Value for URL is invalid"
        case .invalidMethodString:
            return "Could not parse method parameter"
        case .invalidHeaders:
            return "Could not parse headers parameter"
        }
    }
    
    /// Identifies the diagnostic comes from our domain
    var diagnosticID: MessageID {
        MessageID(domain: "MacpluginsMacros", id: rawValue)
    }
}

/// Expands out information into an expression that resolves into an URLRequest
public struct BuildURLRequestMacro: ExpressionMacro {
    /// Expand a macro described by the given freestanding macro expansion
    /// within the given context to produce an instance of an URLRequest.
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Extract out the first parameter
        var result: String?
        
        if let expression = node.argumentList.firstUnlabeled?.expression {
            if let declarationLiteral = expression.as(DeclReferenceExprSyntax.self) {
                result = "\(declarationLiteral)"
            } else if let stringLiteral = expression.as(StringLiteralExprSyntax.self),
                      stringLiteral.trimmedLength.utf8Length > 2 {
                result = "\(stringLiteral)"
            } else {
                result = nil
            }
        }
        
        // Verify we have that parameter
        guard let finalValue = result else {
            context.diagnose(Diagnostic(node: node, message: BuildURLRequestMacroDiagnostic.invalideURLString))
            
            return "nil as URLRequest?"
        }
        
        // First line of the code block being returned.  Define the URL that will be used in the request
        let urlStatement = CodeBlockItemSyntax(item: .stmt("""
                guard let url = URL(string: \(raw: finalValue)) else {
                    return nil
                }
                """)
        )
        
        // Create the request here after making the URL instance
        let urlRequestDeclaration = CodeBlockItemSyntax(item: .decl("var result = URLRequest(url: url)"))
        
        // Will hold the method statement
        let methodExpression: CodeBlockItemSyntax
        
        // Will hold the headers statement
        let headersStatements: CodeBlockItemSyntax
        
        // Get the method
        if let expression = node.argumentList.first(labeled: "method")?.expression {
            let result: String?
            
            if let declarationLiteral = expression.as(DeclReferenceExprSyntax.self) {
                result = "\(declarationLiteral)"
            } else if let stringLiteral = expression.as(StringLiteralExprSyntax.self),
                      stringLiteral.trimmedLength.utf8Length > 2 {
                result = "\(stringLiteral)"
            } else {
                result = nil
            }
            
            guard let method = result else {
                context.diagnose(Diagnostic(node: node, message: BuildURLRequestMacroDiagnostic.invalidMethodString))
                
                return "nil as URLRequest?"
            }
            
            methodExpression = CodeBlockItemSyntax(item: .expr("result.httpMethod = \(raw: method)"))
        } else {
            methodExpression = CodeBlockItemSyntax(item: .expr(#"result.httpMethod = "GET""#))
        }

        if let expression = node.argumentList.first(labeled: "headers")?.expression {
            let result: String?

            if let declarationLiteral = expression.as(DeclReferenceExprSyntax.self) {
                result = "\(declarationLiteral)"
            } else if let dictionaryElement = expression.as(DictionaryElementListSyntax.self) {
                result = "\(dictionaryElement)"
            } else if let dictionaryElement = expression.as(DictionaryExprSyntax.self) {
                result = "\(dictionaryElement)"
            } else {
                result = nil
            }
            
            guard let headers = result else {
                context.diagnose(Diagnostic(node: node, message: BuildURLRequestMacroDiagnostic.invalidHeaders))
                
                return "nil as URLRequest?"
            }
            
            headersStatements = CodeBlockItemSyntax(item: .decl("let headers: [String:String] = \(raw: headers)"))
        } else {
            headersStatements = CodeBlockItemSyntax(item: .decl("let headers: [String:String] = [:]"))
        }
        
        // Block of code that assigns the header values into the request.
        let headerAssignmentStatement = CodeBlockItemSyntax(item: .stmt("""
                for (header, value) in headers {
                    result.setValue(value, forHTTPHeaderField: header)
                }
                """)
        )
        
        // Last line of the block -- return the URLRequest object
        let returnStatement = CodeBlockItemSyntax(item: .stmt("return result"))
        
        // Create a list of statements that will go into the block/closure in the order given.
        let statementList = CodeBlockItemListSyntax(arrayLiteral: urlStatement, urlRequestDeclaration, methodExpression, headersStatements, headerAssignmentStatement, returnStatement)
        
        // Create the closure from that statement list
        let closure = ClosureExprSyntax(statements: statementList)
        
        // Add the call () to the closure so the value is assigned to the variable.
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
