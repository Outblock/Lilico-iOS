//
//  BackAppBar.swift
//  Lilico
//
//  Created by cat on 2022/5/31.
//

import SwiftUI

struct BackAppBar: View {
    var onBack: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Button {
                onBack()
            } label: {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.LL.Neutrals.neutrals1)
                    .frame(width: 54, height: 30)
            }
            Spacer()
        }
        .frame(height: 44)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NFTNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        BackAppBar {}
    }
}
