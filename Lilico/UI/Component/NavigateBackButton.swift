//
//  NavigateBackButton.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import SwiftUI

var btnBack : some View {
    Button{
        
    } label: {
        HStack {
            Image(systemName: "arrow.backward")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
        }
    }
}
