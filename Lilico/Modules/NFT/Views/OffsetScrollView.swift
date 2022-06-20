//
//  OffsetScrollView.swift
//  Sky
//
//  Created by cat on 2022/6/1.
//

import SwiftUI

struct OffsetScrollView<Content: View>: View {
    
    
    @Binding var offset: CGFloat
    
    let content: Content
    
    init(offset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._offset = offset
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { geo in
                Color.clear
                    .preference(key: NavigationScrollPreferenKey.self,
                                value: geo.frame(in: .named("ScrollView")).minY
                    )
            }
            .frame(width: 0,height: 0)
            content
        }
        .frame(alignment: .top)
        .coordinateSpace(name: "ScrollView")
        .onPreferenceChange(NavigationScrollPreferenKey.self) { value in
            self.offset = value
        }
        

    }
}

class NavigationScrollPreferenKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    }
}

struct NavigationScrollView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OffsetScrollView(offset: .constant(1)) {
            LazyVStack {
                ForEach(0..<200) { index in
                    Text("Row number \(index)")
                        .padding()
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
