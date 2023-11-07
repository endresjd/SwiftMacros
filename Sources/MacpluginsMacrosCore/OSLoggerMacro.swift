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
            return "subsystem must be a non-empty quoted string"
        case .badCategoryValue:
            return "category must be a non-empty quoted string"
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

        // Name to use for the logger variable
        var variableName = "\"logger\""
        
        // Subsystem to use for the logger if we don't have a bundle identifier.
        // Can be further overridden by parameters
        var subsystem = ""
        
        // Category that can be further overridden
        var category = "\"\(typeName.text)\""

        // This will be an array of LabeledExprListSyntax
        if case let .argumentList(arguments) = node.arguments {
            for argument in arguments {
                switch argument.label?.text {
                case "subsystem":
                    subsystem = argument.expression.trimmedDescription
                case "category":
                    category = argument.expression.trimmedDescription
                default:
                    variableName = argument.expression.trimmedDescription
                }
            }
        }
        
        guard verifyString(variableName) else {
            context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badLoggerNameValue))

            return []
        }
        
        guard verifyString(subsystem) else {
            context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badSubsystemValue))

            return []
        }

        guard verifyString(category) else {
            context.diagnose(Diagnostic(node: node, message: OSLoggerDiagnostic.badCategoryValue))

            return []
        }
        
        return [
            """
            private let \(raw: variableName.filter { $0 != "\"" }) = Logger(subsystem: \(raw: subsystem), category: \(raw: category))
            """
        ]
    }
    
    /// Verifies we have a properly quoted string passed in
    /// - Parameter string: string to check
    /// - Returns: true if it is good, false if it is not
    static func verifyString(_ string: String) -> Bool {
        // Must be a double quoted value, so minimum is "x", or count of 3
        return string.count > 3 && string.hasPrefix("\"") && string.hasSuffix("\"")
    }
}
