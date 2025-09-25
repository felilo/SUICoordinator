//
//  AnyCoordinator.swift
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

import SwiftUI
@testable import SUICoordinator

class AnyCoordinator: Coordinator<AnyEnumRoute> {
    override func start() async {
        await startFlow(route: .pushStep(1))
    }
}

class OtherCoordinator: Coordinator<DefaultRoute> { 
    override func start() async {
        let page = AnyEnumRoute.pushStep(1)
        await startFlow(route: .init(presentationStyle: page.presentationStyle, content: { page }))
    }
}

class ThirdCoordinator: Coordinator<DefaultRoute> {
    override func start() async {
        let page = AnyEnumRoute.pushStep(1)
        await startFlow(route: .init(presentationStyle: page.presentationStyle, content: { page }))
    }
}
