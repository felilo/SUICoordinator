//
//  CoordinatorMacroError.swift
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

import SwiftDiagnostics
import SwiftSyntax

enum CoordinatorMacroDiagnostic: DiagnosticMessage {
    case notAClass
    case missingRouteType

    var message: String {
        switch self {
        case .notAClass:
            return "@Coordinator can only be applied to a class declaration"
        case .missingRouteType:
            return "@Coordinator requires a RouteType argument, e.g. @Coordinator(HomeRoute.self)"
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notAClass:
            return MessageID(domain: "SUICoordinatorMacros", id: "notAClass")
        case .missingRouteType:
            return MessageID(domain: "SUICoordinatorMacros", id: "missingRouteType")
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .notAClass, .missingRouteType:
            return .error
        }
    }
}

enum CoordinatorMacroError: Error, CustomStringConvertible {
    case notAClass
    case missingRouteType

    var description: String {
        switch self {
        case .notAClass:
            return "@Coordinator can only be applied to a class declaration"
        case .missingRouteType:
            return "@Coordinator requires a RouteType argument, e.g. @Coordinator(HomeRoute.self)"
        }
    }
}
