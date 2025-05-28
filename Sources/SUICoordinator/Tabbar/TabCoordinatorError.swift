//
//  TabbarCoordinatorError.swift
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

import Foundation

/// An enumeration representing errors specific to tab coordinator operations.
///
/// `TabCoordinatorError` provides specific error cases that can occur during tab coordinator
/// operations, particularly when dealing with coordinator selection and management.
///
/// These errors help developers identify and handle issues that may arise when working
/// with tab-based navigation coordinators.
public enum TabCoordinatorError: LocalizedError {
    
    /// An error case indicating that no coordinator is selected or the selected coordinator cannot be found.
    ///
    /// This error typically occurs when:
    /// - Attempting to retrieve the currently selected coordinator but no valid selection exists
    /// - The selected tab's coordinator is not properly initialized or configured
    /// - There's a mismatch between the current page and the available child coordinators
    case coordinatorSelected
    
    // ---------------------------------------------------------
    // MARK: LocalizedError
    // ---------------------------------------------------------
    
    /// A computed property providing a localized description for the error.
    ///
    /// This property returns user-friendly error messages that can be displayed to users
    /// or used for debugging purposes.
    ///
    /// - Returns: A localized string describing the specific error that occurred.
    public var errorDescription: String? {
        switch self {
            case .coordinatorSelected:
                return "There is no coordinator selected or the selected coordinator cannot be found."
        }
    }
}
