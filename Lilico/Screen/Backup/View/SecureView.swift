//
//  SecureView.swift
//  SwiftTest
//
//  Created by cat on 2022/5/10.
//

import SwiftUI

struct SecureView: View {
    @Binding var text: String
    var maxCount: Int = 6
    var emptyColor: Color = .LL.Neutrals.outline
    var highlightColor: Color = .LL.Primary.salmonPrimary
    var handler: (String, Bool) -> Void
    
    private let spacing = 24.0
    private let itemSize = 20.0
    private var maxWidth: Double {
        (spacing + itemSize) * Double(maxCount) - spacing
    }
    
    var body: some View {
        
        HStack {
            Spacer()
            ZStack(alignment: .leading) {
                HStack(spacing: spacing){
                    ForEach(0..<maxCount,id: \.self) { index in
                        DotView(color: emptyColor, size: itemSize)
                    }
                }
                
                HStack(spacing: spacing) {
                    ForEach(0..<min(maxCount, text.count),id: \.self) { index in
                        DotView(color: highlightColor, size: itemSize)
                    }
                }
                
                TextField("", text: $text)
                    .foregroundColor(Color.clear)
                    .accentColor(Color.clear)
                    .onChange(of: text) { newValue in
                        if(text.count > maxCount) {
                            text = String(text[text.startIndex...text.index(text.startIndex, offsetBy: maxCount-1)])
                        }
                        handler(text, text.count ==  maxCount)
                    }
                    .frame(width: maxWidth)
            }
            Spacer()
        }
        
    }
}

private struct DotView: View {
    var color: Color
    var size: Double
    var body: some View {
        Circle()
            .frame(width: size, height: size, alignment: .center)
            .foregroundColor(color)
    }
}

struct SecureView_Previews: PreviewProvider {
    @State static var content: String = ""
    static var previews: some View {
        Group {
            SecureView(text: $content) { content, res in
                
            }
            SecureView(text: $content) { content, res in
                
            }
            .preferredColorScheme(.dark)
        }
    }
}


