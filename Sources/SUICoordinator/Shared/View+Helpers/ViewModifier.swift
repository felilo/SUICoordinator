//
//  AAA.swift
//  CRNavigation
//
//  Created by Andres Lozano on 26/12/23.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
	@State private var viewDidLoad = false
	public let action: (() -> Void)?
	
	public func body(content: Content) -> some View {
		content
			.onAppear {
				if !viewDidLoad {
					viewDidLoad.toggle()
					action?()
				}
			}
	}
}
