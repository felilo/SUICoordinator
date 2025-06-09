//
//  AnyEnumRoute.swift
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


enum AnyEnumRoute: RouteType {
    
    case pushStep(_ num: Int? = nil)
    case pushStep2
    case pushStep3
    case fullScreenStep
    case sheetStep
    case detentsStep
    case customTransition(fullScreen: Bool = true)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .pushStep, .pushStep2, .pushStep3: return .push
        case .fullScreenStep: return .fullScreenCover
        case .sheetStep: return .sheet
        case .detentsStep: return .detents([.medium])
        case .customTransition(let fullScreen): return .custom(transition: .move(edge: .bottom), animation: nil, fullScreen: fullScreen)
        }
    }
    
    var body: some View {
        switch self {
        case .pushStep:
            PushStepView()
        case .pushStep2:
            PushStep2View()
        case .pushStep3:
            PushStep3View()
        case .fullScreenStep:
            FullScreenStepView()
        case .sheetStep:
            Text("sheetStep")
        case .detentsStep:
            Text("detentsStep")
        case .customTransition(_):
            CustomTransitionView()
        }
    }
}

struct PushStepView: View {
    
    let someParameter: Bool
    
    init(someParameter: Bool) {
        self.someParameter = someParameter
    }
    
    init() {
        self.init(someParameter: true)
    }
    
    
    var body: some View {
        Text("pushStep")
    }
}

struct PushStep2View: View {
    var body: some View {
        Text("PushStep2View")
    }
}

struct PushStep3View: View {
    var body: some View {
        Text("PushStep3View")
    }
}

struct FullScreenStepView: View {
    var body: some View {
        Text("FullScreenStepView")
    }
}

struct CustomTransitionView: View {
    var body: some View {
        Text("FullScreenStepView")
    }
}
