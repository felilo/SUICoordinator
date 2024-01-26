//
//  Protocols.swift
//  Navigation
//
//  Created by Andres Lozano on 30/11/23.
//

import Foundation

// ---------------------------------------------------------
// MARK: RCEquatable
// ---------------------------------------------------------

/**
 A protocol that extends `RCIdentifiable` and `Equatable`, providing default implementation for equality based on identifier.

 Conforming types must implement `RCIdentifiable`.

 - SeeAlso: `RCIdentifiable`
 */
public protocol SCEquatable: SCIdentifiable, Equatable {}

public extension SCEquatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}


// ---------------------------------------------------------
// MARK: RCIdentifiable
// ---------------------------------------------------------

/**
 A protocol that inherits from `Identifiable`, providing a default identifier implementation based on the type's name.

 Conforming types automatically get an identifier based on their type name.

 - Important: The identifier is based on the type name using `String(describing: self.self)`.

 - SeeAlso: `Identifiable`
 */
public protocol SCIdentifiable: Identifiable {}

extension SCIdentifiable {
	/// The default identifier based on the type's name.
	public var id: String {
		let string = String(describing: self.self)
		return string
	}
}


// ---------------------------------------------------------
// MARK: CRHashable
// ---------------------------------------------------------

/**
 A protocol that extends `RCIdentifiable` and `Hashable`, providing default implementation for hashing based on identifier.

 Conforming types must implement `RCIdentifiable`.

 - SeeAlso: `RCIdentifiable`, `Hashable`
 */
public protocol SCHashable: SCIdentifiable, Hashable {}

extension SCHashable {
	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id)
	}
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}

// ---------------------------------------------------------
// MARK: CoordinatableView
// ---------------------------------------------------------

/**
 A protocol for views associated with coordinators.

 Conforming types should implement a `clean` method to perform cleanup when the view is being dismissed or deallocated.
 */
protocol CoordinatorViewType {
	/// Cleans up resources associated with the view.
	func clean() -> Void
}
