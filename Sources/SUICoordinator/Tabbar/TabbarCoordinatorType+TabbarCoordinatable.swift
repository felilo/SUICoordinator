//
//  TabbarCoordinatorType+TabbarCoordinatable.swift
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

extension TabbarCoordinatorType where Self : TabbarCoordinatable {
    
    /// Sets the array of pages for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - values: The array of pages to set.
    ///   - currentPage: The optional current page to set.
    public func setPages(_ values: [Page], currentPage: Page? = nil) async {
        await removeChildren()
        setupPages(values, currentPage: currentPage)
    }
    
    /// Sets up the pages for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - value: The array of pages to set up.
    func setupPages(_ value: [Page], currentPage: Page? = nil) {
        for page in value {
            let item = page.coordinator()
            startChildCoordinator(item)
            item.tagId = "\(page.position)"
        }
        
        pages = value
        setCurrentPage(currentPage)
    }
}
