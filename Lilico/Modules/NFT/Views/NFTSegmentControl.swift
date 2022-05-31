//
//  NFTSegmentControl.swift
//  Lilico
//
//  Created by cat on 2022/5/31.
//

import SwiftUI

struct NFTSegmentControl: View {
    
    @Binding var currentTab: String
    var titles:[String];

    @Namespace var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(titles, id: \.self) { title in
                NFTSegmentItem(title: title, animation: animation, current: $currentTab)
                    
            }
        }
        .padding(4)
        .background(.LL.Button.light.opacity(0.24))
        .cornerRadius(16)
    }
}

struct NFTSegmentItem: View {
    var title: String
    let animation: Namespace.ID
    
    @Binding var current: String
    
    var body: some View {
        Text(title)
            .font(.LL.body)
            .fontWeight(.w700)
            .foregroundColor(current == title ? .LL.Neutrals.text : .LL.Shades.front)
            .frame(height: 20)
            .padding(.vertical,2)
            .padding(.horizontal, 13)
            .background(
                ZStack{
                    if (current == title) {
                        Color.white
                            .cornerRadius(16)
                            .matchedGeometryEffect(id: "Segment", in: animation)
                    }
                }
            )
            .animation(.easeInOut, value: current)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6)) {
                    current = title
                }
            }
    }
}

struct NFTSegmentControl_Previews: PreviewProvider {
    @State static var current: String = "List"
    static var previews: some View {
        NFTSegmentControl(currentTab: $current, titles: ["List", "Grid"])
            .background(Color.black)
    }
}
