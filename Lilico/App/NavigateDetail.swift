//
//  NavigateDetail.swift
//  Lilico
//
//  Created by Hao Fu on 5/1/22.
//

import SwiftUI

struct NavigationDetailDemo: View {
    var body: some View {
        List {
            ForEach(1 ..< 40) { _ in
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
        .toolbar(content: {
            navigationBarItems(leading: Text("做"))
        })
    }
}

struct NavigationDetailDemo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDetailDemo()
    }
}
