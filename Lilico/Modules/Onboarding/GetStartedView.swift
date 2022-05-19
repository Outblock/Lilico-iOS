//
//  GetStartedView.swift
//  Lilico
//
//  Created by Hao Fu on 16/12/21.
//

import SwiftUI

struct GetStartedView: View {
    var body: some View {
        VStack {
            Spacer()
            Button {} label: {
                Text("Get Started")
            }
            .tint(Color.LL.background)
            .padding()
            .background(Color.LL.orange)
            .cornerRadius(10)
        }
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
