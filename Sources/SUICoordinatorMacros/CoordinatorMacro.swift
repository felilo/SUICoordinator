//
//  CoordinatorMacro.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// Coordinator-owned stored properties that need @ObservationTracked
private let coordinatorPropertyNames: Set<String> = [
    "router", "uuid", "parent", "children", "tagId"
]

public struct CoordinatorMacro {}

// MARK: - MemberMacro

extension CoordinatorMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Validate: must be a class (diagnostic emitted by ExtensionMacro)
        guard declaration.is(ClassDeclSyntax.self) else {
            return []
        }

        // Extract Route type name from @Coordinator(HomeRoute.self)
        guard let routeTypeName = extractRouteTypeName(from: node) else {
            context.diagnose(Diagnostic(node: node, message: CoordinatorMacroDiagnostic.missingRouteType))
            throw CoordinatorMacroError.missingRouteType
        }

        let existingMemberNames = collectExistingMemberNames(from: declaration)

        var members: [DeclSyntax] = []

        // ── Coordinator protocol requirements ──────────────────────────────

        if !existingMemberNames.contains("router") {
            members.append("public var router: Router<\(raw: routeTypeName)> = .init()")
        }
        if !existingMemberNames.contains("uuid") {
            members.append(
                """
                public lazy var uuid: String = "\\(NSStringFromClass(type(of: self))) - \\(UUID().uuidString)"
                """
            )
        }
        if !existingMemberNames.contains("parent") {
            members.append("public var parent: (any CoordinatorType)?")
        }
        if !existingMemberNames.contains("children") {
            members.append("public var children: [(any CoordinatorType)] = []")
        }
        if !existingMemberNames.contains("tagId") {
            members.append("public var tagId: String?")
        }
        if !existingMemberNames.contains("init") {
            members.append("public nonisolated init() {}")
        }

        // ── Observation infrastructure (replaces @Observable) ─────────────

        if !existingMemberNames.contains("_$observationRegistrar") {
            members.append(
                "@ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()"
            )
        }
        if !existingMemberNames.contains("access") {
            members.append(
                """
                public nonisolated func access<Member>(
                    keyPath: KeyPath<\(raw: typeName(of: declaration)), Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
                """
            )
        }
        if !existingMemberNames.contains("withMutation") {
            members.append(
                """
                public nonisolated func withMutation<Member, T>(
                    keyPath: KeyPath<\(raw: typeName(of: declaration)), Member>,
                    _ mutation: () throws -> T
                ) rethrows -> T {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
                """
            )
        }

        return members
    }
}

// MARK: - MemberAttributeMacro

extension CoordinatorMacro: MemberAttributeMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else { return [] }

        // Add @ObservationTracked to stored var members
        if let varDecl = member.as(VariableDeclSyntax.self),
           varDecl.bindingSpecifier.tokenKind == .keyword(.var),
           let firstBinding = varDecl.bindings.first,
           let patternName = firstBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
           patternName != "_$observationRegistrar",
           firstBinding.accessorBlock == nil {
            return [AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("ObservationTracked")))]
        }

        // Add @MainActor to instance func members so they inherit
        // the same isolation as CoordinatorType (@MainActor protocol)
        if let funcDecl = member.as(FunctionDeclSyntax.self) {
            let isStatic = funcDecl.modifiers.contains { $0.name.tokenKind == .keyword(.static) }
            let alreadyMainActor = funcDecl.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "MainActor"
            }
            if !isStatic && !alreadyMainActor {
                return [AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("MainActor")))]
            }
        }

        return []
    }
}

// MARK: - ExtensionMacro

extension CoordinatorMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: CoordinatorMacroDiagnostic.notAClass))
            return []
        }

        // CoordinatorType conformance + Observable conformance
        let coordinatorExt: DeclSyntax =
            """
            @available(iOS 17.0, *)
            extension \(type.trimmed): CoordinatorType {}
            """
        let observableExt: DeclSyntax =
            """
            extension \(type.trimmed): Observable {}
            """

        guard
            let coordinatorExtDecl = coordinatorExt.as(ExtensionDeclSyntax.self),
            let observableExtDecl = observableExt.as(ExtensionDeclSyntax.self)
        else {
            return []
        }
        return [coordinatorExtDecl, observableExtDecl]
    }
}

// MARK: - Helpers

extension CoordinatorMacro {

    /// Extracts the route type name from the macro attribute argument.
    /// Handles both `HomeRoute.self` and bare `HomeRoute`.
    static func extractRouteTypeName(from node: AttributeSyntax) -> String? {
        guard
            let arguments = node.arguments?.as(LabeledExprListSyntax.self),
            let firstArg = arguments.first?.expression
        else { return nil }

        if let memberAccess = firstArg.as(MemberAccessExprSyntax.self),
           memberAccess.declName.baseName.text == "self",
           let base = memberAccess.base {
            return base.trimmedDescription
        }

        if let declRef = firstArg.as(DeclReferenceExprSyntax.self) {
            return declRef.baseName.text
        }

        return nil
    }

    /// Returns the type name of a class declaration.
    static func typeName(of declaration: some DeclGroupSyntax) -> String {
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl.name.text
        }
        return "Self"
    }

    /// Returns the set of member names already present in the declaration.
    static func collectExistingMemberNames(from declaration: some DeclGroupSyntax) -> Set<String> {
        var names = Set<String>()
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                for binding in varDecl.bindings {
                    names.insert(binding.pattern.trimmedDescription)
                }
            } else if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                names.insert(funcDecl.name.text)
            } else if member.decl.is(InitializerDeclSyntax.self) {
                names.insert("init")
            }
        }
        return names
    }
}
