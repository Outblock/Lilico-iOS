//
//  View.swift
//  Lilico-lite
//
//  Created by Hao Fu on 27/11/21.
//

import SwiftUI

extension View {
    var screenBounds: CGRect {
        UIScreen.main.bounds
    }
    
    var screenWidth: CGFloat {
        screenBounds.width
    }
    
    var screenHeight: CGFloat {
        screenBounds.height
    }
}
