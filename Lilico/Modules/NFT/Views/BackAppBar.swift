//
//  BackAppBar.swift
//  Lilico
//
//  Created by cat on 2022/5/31.
//

import SwiftUI

struct BackAppBar: View {
    var title: String?
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
        .overlay() {
            if let title = self.title {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.LL.Neutrals.text)
                    .frame(maxWidth: screenWidth - 90)
            }
        }
        .frame(height: 44, alignment: .center)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NFTNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        BackAppBar(title: "I'm a Title,too long long long  long long ") {}
    }
}
