//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  OSLogger.swift
//  
//
//  Created by John Endres on 11/4/23.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Diagnostic information for this macro.
private enum OSLoggerDiagnostic: String, DiagnosticMessage {
    /// This macro has been attached to the wrong type.
    case wrongType
    
    /// logger name is not a quoted string of 1 or more characters
    case badLoggerNameValue
    
    /// subsystem is not a quoted string of 1 or more characters
    case badSubsystemValue
    
    /// category is not a quoted string of 1 or more characters
    case badCategoryValue
    
    /// Severity of this diagnostic
    var severity: DiagnosticSeverity {
        switch self {
        case .wrongType, .badLoggerNameValue, .badSubsystemValue, .badCategoryValue:
            return .error
        }
    }
    
    /// User visibile message for a given case.
    var message: String {
        switch self {
        case .wrongType:
            return "OSLogger can only be attached to class or struct"
        case .badLoggerNameValue:
            return "loggerName must be a non-empty quoted string"
        case .badSubsystemValue:
            return "Unspupported value for subsystem"
        case .badCategoryValue:
            return "Unspupported value for category"
        }
    }
    
    /// Identifies the diagnostic comes from our domain
    var diagnosticID: MessageID {
        MessageID(domain: "MacpluginsMacros", id: rawValue)
    }
}

/// Implementation of the `OSLogger` macro, which takes a string
/// and prints the class and issue only during debugging. For example
///
///     import Logger
///
///     @OSLogger
///     class Foo {
///         func failure() {
///             ....
///             log(issue: "failed")
///         }
///     }
///
///  Will print out - "[MacpluginsMacrosClient] failed"
public struct OSLoggerMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // Make sure this is attached to the right things!
        let typeName: TokenSyntax
        
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            typeName = classDecl.name
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            typeName = structDecl.name
        } else {
            context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.wrongType))
            
            return []
        }

        // Default name to use for the logger variable
        var variableName = "logger"
        
        // Default subsystem name.  Try to use Bundle.main.bundleIdentifier
        var subsystem = #"Bundle.main.bundleIdentifier ?? "Unknown""#
        
        // Default category name
        var category = "\"\(typeName.text)\""

        // Parse out the arguments
        // Declarations (DeclReferenceExprSyntax) in the argument list would be variables passed in
        // Strings (StringLiteralExprSyntax) in the argument list would be a hard-coded string
        // This will be an array of LabeledExprListSyntax
        if case let .argumentList(arguments) = node.arguments {
            // Verify variable name is a string, and it is populated
            if let variableNameArg = arguments.firstUnlabeled {
                if let stringLiteral = variableNameArg.expression.as(StringLiteralExprSyntax.self),
                   stringLiteral.segments.count == 1,
                   case let .stringSegment(variableNameString) = stringLiteral.segments.first,
                   !variableNameString.trimmedDescription.filter({ $0 != "\"" }).isEmpty {
                    variableName = variableNameString.trimmedDescription
                } else {
                    context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badLoggerNameValue))
                    
                    return []
                }
            }
            
            if let argument = arguments.first(labeled: "subsystem") {
                if let result = getLabeledArgumentValue(for: argument) {
                    subsystem = result
                } else {
                    context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badSubsystemValue))
                    
                    return []
                }
            }
            
            if let argument = arguments.first(labeled: "category") {
                if let result = getLabeledArgumentValue(for: argument) {
                    category = result
                } else {
                    context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badCategoryValue))
                    
                    return []
                }
            }
        }
        
        return [
            """
            private let \(raw: variableName) = Logger(subsystem: \(raw: subsystem), category: \(raw: category))
            """
        ]
    }
    
    /// Takes the element and breaks it down into the 3 we expect -- Declaration, String, or an expression
    /// and if it is one of those, return the value for that argument.  Part of this is checking that there is
    /// a value in those strings as well.
    /// - Parameter argument: the element to examine
    /// - Returns: string value for that element or nil if they type of the element is wrong
    static func getLabeledArgumentValue(for argument: LabeledExprListSyntax.Element) -> String? {
        let result: String
        
        if let declarationLiteral = argument.expression.as(DeclReferenceExprSyntax.self) {
            result = declarationLiteral.trimmedDescription
        } else if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
            result = stringLiteral.trimmedDescription
        } else if let memberAccessExpression = argument.expression.as(ExprSyntax.self) {
            result = memberAccessExpression.trimmedDescription
        } else {
            return nil
        }
        
        // We need to make sure the value return is not empty or just an empty string literal
        return result.filter { $0 != "\"" }.isEmpty ? nil : result
    }
}
