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
    case missingString
    
    /// Severity of this diagnostic
    var severity: DiagnosticSeverity {
        switch self {
        case .missingString:
            return .error
        }
    }
    
    /// User visibile message for a given case.
    var message: String {
        switch self {
        case .missingString:
            return "Missing URL string"
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
        // Get the first parameter, the one with no label, the one that has the label ignored in the
        // declaration of the macro.
        guard let value = node.argumentList.first(where: { $0.label == nil })?.expression else {
            // I don't see a way to get here.  The macro definition requires this field in its
            // signature and will cause a compile error before the macro is called.  This raises
            // a diagnostic just in case.
            context.diagnose(Diagnostic(node: node, message: BuildURLRequestMacroDiagnostic.missingString))
            
            return ""
        }
        
        // First line of the code block being returned.  Define the URL that will be used in the request
        let urlStatement = CodeBlockItemSyntax(item: .stmt("""
                guard let url = URL(string: \(raw: value)) else {
                    return nil
                }
                """)
        )
        
        // Create the request here after making the URL instance
        let urlRequestDeclaration = CodeBlockItemSyntax(item: .decl("var result = URLRequest(url: url)"))
        
        // Default values for the optional macro parameters.  They don't seem to be passed
        // of, more likely, I don't see how to get them yet, so default to what is in the macro
        // definition.
        var methodExpression = CodeBlockItemSyntax(item: .expr(#"result.httpMethod = "GET""#))
        var headersStatements = CodeBlockItemSyntax(item: .decl("let headers: [String:String] = [:]"))
        
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
                        headersStatements = CodeBlockItemSyntax(item: .decl("let headers: [String:String] = \(tupleExprElementSyntax.expression)"))
                    default:
                        break
                    }
                }
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
