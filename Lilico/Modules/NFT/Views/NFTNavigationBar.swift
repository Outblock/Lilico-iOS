//
//  NFTNavigationBar.swift
//  Lilico
//
//  Created by cat on 2022/5/31.
//

import SwiftUI

struct NFTNavigationBar: View {
    
    var title: String = ""
    
    @Binding var opacity: Double
    var onBack: () -> Void
    
    var body: some View {
        
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(opacity)
            
                
            HStack(alignment: .center) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.LL.Neutrals.neutrals1)
                        .frame(width: 54, height: 30)
                }
                
                Spacer()
                
                Text(title)
                    .font(.title2)
                    .opacity(opacity)
                
                Spacer()
                
                Color.clear
                    .frame(width: 54)
            }
            
        }
        .frame(height: 44)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

struct NFTNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        
        NFTNavigationBar(title: "Feature", opacity: .constant(1)) {
            
        }
    }
}
