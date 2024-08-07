//
//  EquatableMacro.swift
//
//
//  Created by Endres, John on 8/5/24.
//
 
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
 
public struct EquatableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let equatableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Equatable {}")
        
        return [equatableExtension]
    }
}
