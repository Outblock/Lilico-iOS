//
//  ContentView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Color.yellow.frame(width: 50, height: 50, alignment: .center)

            Color.red.frame(width: 50, height: 50, alignment: .center)
                .rotationEffect(.degrees(45))
                .padding(-20)
                .blendMode(.luminosity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView().colorScheme(.dark)
        }
    }
}
