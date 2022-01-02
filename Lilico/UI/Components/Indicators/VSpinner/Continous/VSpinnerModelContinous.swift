//
//  VSpinnerModelContinous.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/21/20.
//

import SwiftUI

// MARK: - V Spinner Model Continous
/// Model that describes UI.
public struct VSpinnerModelContinous {
    // MARK: Properties
    /// Sub-model containing layout properties.
    public var layout: Layout = .init()
    
    /// Sub-model containing color properties.
    public var colors: Colors = .init()
    
    /// Sub-model containing animation properties.
    public var animations: Animations = .init()
    
    // MARK: Initializers
    /// Initializes model with default values.
    public init() {}

    // MARK: Layout
    /// Sub-model containing layout properties.
    public struct Layout {
        // MARK: Properties
        /// Spinner dimension. Defaults to `15`.
        public var dimension: CGFloat = 15
        
        /// Length of colored part of spinner. Defaults to `0.75`.
        public var legth: CGFloat = 0.75
        
        /// Spinner thickness. Defaults to `2`.
        public var thickness: CGFloat = 2
        
        // MARK: Initializers
        /// Initializes sub-model with default values.
        public init() {}
    }

    // MARK: Colors
    /// Sub-model containing color properties.
    public struct Colors {
        // MARK: Properties
        /// Spinner color.
        public var spinner: Color = ColorBook.accent
        
        // MARK: Initializers
        /// Initializes sub-model with default values.
        public init() {}
    }

    // MARK: Animations
    /// Sub-model containing animation properties.
    public struct Animations {
        // MARK: Properties
        /// Spinner animation. Defaults to `linear` with duration `0.75`.
        public var spinning: Animation = .linear(duration: 0.75)
        
        // MARK: Initializers
        /// Initializes sub-model with default values.
        public init() {}
    }
}
