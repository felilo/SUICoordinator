//
//  TabbarCoordinatorType+Helpers.swift
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

extension TabCoordinatorType {
    
    /// Sets the current page for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator.
    @MainActor func setCurrentPage(with coordinator: any CoordinatorType) {
        let page = pages.first(where: { "\($0.position)" == coordinator.tagId })
        
        setCurrentPage(page)
    }
    
    /// Sets the current page for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - value: The optional current page to set.
    @MainActor public func setCurrentPage(_ value: (any TabbarPage)?) {
        guard let value, value.position != currentPage.position,
              let item = pages.first(where: { $0.position == value.position })
        else { return  }
        
        currentPage = item
    }
    
    @MainActor public func popToRoot() async {
        try? await getCoordinatorSelected().root.popToRoot(animated: true)
    }
}
