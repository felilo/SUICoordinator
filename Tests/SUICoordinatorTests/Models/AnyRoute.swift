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
    
    case pushStep
    case pushStep2
    case pushStep3
    case fullScreenStep
    case sheetStep
    case detentsStep
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .pushStep, .pushStep2, .pushStep3: return .push
            case .fullScreenStep: return .fullScreenCover
            case .sheetStep: return .sheet
            case .detentsStep: return .detents([.medium])
        }
    }
    
    var view: Body {
        switch self {
            case .pushStep:
                return PushStepView()
            case .pushStep2:
                return PushStep2View()
            case .pushStep3:
                return PushStep3View()
            case .fullScreenStep:
                return FullScreenStepView()
            case .sheetStep:
                return Text("sheetStep")
            case .detentsStep:
                return Text("detentsStep")
        }
    }
}

struct PushStepView: View {
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



struct AnyStructRoute: RouteType {
    
    var _presentationStyle: TransitionPresentationStyle
    var presentationStyle: TransitionPresentationStyle { _presentationStyle }
    var view: Body { Text("AnyStructRoute") }
    
    init(presentationStyle: TransitionPresentationStyle) {
        _presentationStyle = presentationStyle
    }
}
