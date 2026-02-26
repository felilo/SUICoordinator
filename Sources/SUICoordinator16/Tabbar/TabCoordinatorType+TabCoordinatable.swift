//
//  TabCoordinatorType+TabCoordinatable.swift
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

/// An extension providing default implementations for tab coordinator management.
///
/// This extension adds convenience methods to types that conform to both `TabCoordinatorType`
/// and `TabCoordinatable`, simplifying common operations like page management and coordinator setup.
extension TabCoordinatorType where Self : TabCoordinatable {
    
    /// Sets the array of pages for the tab coordinator.
    ///
    /// This method replaces the current set of pages with a new array and optionally updates
    /// the current page. It performs cleanup of existing child coordinators before setting up
    /// the new pages.
    ///
    /// - Parameters:
    ///   - values: The array of pages to set. Each page will have its corresponding coordinator
    ///             created and added as a child coordinator.
    ///   - currentPage: The optional current page to set. If provided, this page will become
    ///                  the selected tab. If `nil`, the current page selection remains unchanged.
    ///
    /// - Important: This method removes all existing child coordinators before adding new ones.
    ///              Make sure to call this method when you need to completely replace the tab structure.
    public func setPages(_ values: [Page], currentPage: Page? = nil) async {
        await removeChildren()
        await setupPages(values, currentPage: currentPage)
    }
    
    /// Sets up the pages for the tab coordinator.
    ///
    /// This internal method creates child coordinators for each page and configures them
    /// with appropriate tag identifiers. It's used both during initialization and when
    /// updating the page structure.
    ///
    /// - Parameters:
    ///   - value: The array of pages to set up. Each page will have its coordinator created
    ///            via the `coordinator()` method.
    ///   - currentPage: The optional current page to set as selected. If provided, this page
    ///                  will become the active tab.
    ///
    /// - Note: Each child coordinator's `tagId` is set to match its corresponding page's position
    ///         to enable proper coordination between tabs and their coordinators.
    func setupPages(_ value: [Page], currentPage: Page? = nil) async {
        for page in value {
            let item = page.coordinator()
            
            if children.contains(where: { $0.uuid == item.uuid }) { break }
            
            await item.start()
            startChildCoordinator(item)
            item.tagId = "\(page.id)"
        }
        
        pages = value
        setCurrentPage(currentPage)
    }
}
