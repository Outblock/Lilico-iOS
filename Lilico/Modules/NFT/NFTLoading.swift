//
//  NFTLoading.swift
//  Lilico
//
//  Created by cat on 2022/5/19.
//

import SwiftUI

struct NFTLoading: View {
    var body: some View {
        ZStack{
            Text("Loading...")
                .background(Color.clear)
        }
    }
}

struct NFTLoading_Previews: PreviewProvider {
    static var previews: some View {
        NFTLoading()
    }
}
