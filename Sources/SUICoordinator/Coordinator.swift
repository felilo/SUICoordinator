//
//  Coordinator.swift
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
import Combine
import SwiftUI

/// An open class representing a coordinator in a coordinator-based architecture.
///
/// Coordinators are responsible for coordinating the navigation and flow within an application.
open class Coordinator<Route: RouteType>: ObservableObject, CoordinatorType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The published router associated with the coordinator.
    @Published public var router: Router<Route>
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    public var uuid: String
    
    /// The parent coordinator associated with the coordinator.
    public var parent: (any CoordinatorType)!
    
    /// The array of children coordinators associated with the coordinator.
    public var children: [(any CoordinatorType)] = []
    
    /// The tag identifier associated with the coordinator.
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    /// Initializes a new instance of `Coordinator`.
    public init() {
        self.router = .init()
        self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
        self.router.coordinator = self
    }
    
    // --------------------------------------------------------------------
    // MARK: Computed vars
    // --------------------------------------------------------------------
    
    /// A computed property providing the view associated with the coordinator.
    public var view: any View {
        CoordinatorView(
            viewModel: self,
            onClean: { [weak self] in await self?.clean() },
            onSetTag: { [weak self] tag in self?.tagId = tag }
        )
    }
    
    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------
    
    
    /// Starts the coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process.
    /// - Important: Subclasses should override this method with their own custom implementation.
    open func start(animated: Bool = true) async {
        fatalError("This method must be overwritten")
    }
    
    /// Forces the presentation of the coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///   - presentationStyle: The transition presentation style for the forced presentation.
    ///   - mainCoordinator: The main coordinator associated with the forced presentation.
    ///   - Throws: An error if the presentation cannot be forced.
    ///   SeeAlso: TransitionPresentationStyle
    open func forcePresentation(
        animated: Bool = true,
        presentationStyle: TransitionPresentationStyle = .sheet,
        mainCoordinator: (any CoordinatorType)? = nil
    ) async throws {
        let topCoordinator = try mainCoordinator?.topCoordinator()
        await topCoordinator?.navigate(to: self, presentationStyle: presentationStyle)
    }
    
    /// Cleans up the coordinator.
    private func clean() async {
        await finish(animated: false, withDissmis: false)
    }
}
