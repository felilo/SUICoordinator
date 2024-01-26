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

/**
 An enumeration representing errors specific to `TabbarCoordinatorType`.

 The `TabbarCoordinatorError` enum conforms to the `LocalizedError` protocol to provide localized descriptions for each error case.

 - Important: The `coordinatorSelected` case indicates that there is no coordinator selected.

 Example usage:
 ```swift
 // Handle errors thrown by a TabbarCoordinatorType implementation.
 do {
	 try myTabbarCoordinator.getCoordinatorSelected()
 } catch TabbarCoordinatorError.coordinatorSelected {
	 // Handle the case where there is no coordinator selected.
	 print("Error: There is no coordinator selected.")
 }
 */
public enum TabbarCoordinatorError: LocalizedError {
	
	/// Indicates that there is no coordinator selected.
	case coordinatorSelected
	
	// ---------------------------------------------------------------------
	// MARK: LocalizedError
	// ---------------------------------------------------------------------
	
	/// The localized description for the error.
	public var errorDescription: String? {
		switch self {
			case .coordinatorSelected:
				return "There is no coordinator selected"
		}
	}
}
