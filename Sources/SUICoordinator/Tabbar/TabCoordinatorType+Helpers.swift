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
    
    /// Sets the current page for the tab coordinator based on a child coordinator.
    ///
    /// This method finds the page that corresponds to the provided coordinator by matching
    /// the coordinator's `tagId` with the page's position, then sets it as the current page.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator whose corresponding page should be set as current.
    ///                  The coordinator's `tagId` should match the string representation of a page's position.
    @MainActor func setCurrentPage(with coordinator: any CoordinatorType) {
        let page = pages.first(where: { "\($0.position)" == coordinator.tagId })
        
        setCurrentPage(page)
    }
    
    /// Sets the current page for the tab coordinator.
    ///
    /// This method updates the currently selected tab to the specified page. It performs validation
    /// to ensure the page exists in the coordinator's pages array and is different from the current page
    /// before making the change.
    ///
    /// - Parameters:
    ///   - value: The optional page to set as current. If `nil`, no change will be made.
    ///            The page must exist in the `pages` array and be different from the current page.
    @MainActor public func setCurrentPage(_ value: (any TabPage)?) {
        guard let value, value.position != currentPage.position,
              let item = pages.first(where: { $0.position == value.position })
        else { return  }
        
        currentPage = item
    }
    
    /// Pops all view controllers to the root of the currently selected tab's navigation stack.
    ///
    /// This is a convenience method that calls `popToRoot` on the router of the currently selected
    /// tab coordinator. It's useful for resetting the navigation state of the active tab.
    ///
    /// - Note: This method will attempt to get the currently selected coordinator and pop to its root.
    ///         If the selected coordinator cannot be determined, the operation will fail silently.
    @MainActor public func popToRoot() async {
        try? await getCoordinatorSelected().root.popToRoot(animated: true)
    }
}
