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
    
    /// Severity of this diagnostic
    var severity: DiagnosticSeverity {
        switch self {
        case .wrongType:
            return .error
        }
    }
    
    /// User visibile message for a given case.
    var message: String {
        switch self {
        case .wrongType:
            return "OSLogger can only be attached to class or struct"
        }
    }
    
    /// Identifies the diagnostic comes from our domain
    var diagnosticID: MessageID {
        MessageID(domain: "MacpluginsMacrosImplementation", id: rawValue)
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
        var variableName = "logger"
        
        // Subsystem to use for the logger if we don't have a bundle identifier.
        // Can be further overridden by parameters
        var subsystem = "Unknown"
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            subsystem = bundleIdentifier
        }
        
        // Category that can be further overridden
        var category = typeName.text

        // This will be an array of LabeledExprListSyntax
        if case let .argumentList(arguments) = node.arguments {
            for argument in arguments {
                switch argument.label?.text {
                case "subsystem":
                    subsystem = argument.expression.trimmedDescription.filter { $0 != "\"" }
                case "category":
                    category = argument.expression.trimmedDescription.filter { $0 != "\"" }
                default:
                    variableName = argument.expression.trimmedDescription.filter { $0 != "\"" }
                }
            }
        }
        
        return [
            """
            private let \(raw: variableName) = Logger(subsystem: "\(raw: subsystem)", category: "\(raw: category)")
            """
        ]
    }

}
