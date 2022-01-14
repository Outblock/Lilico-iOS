//
//  CardTest.swift
//  Lilico
//
//  Created by Hao Fu on 13/1/22.
//

import SwiftUI

struct CardTest : View {

    var width = UIScreen.main.bounds.width - (40 + 60)
    var height = UIScreen.main.bounds.height / 2
    
    struct Model {
        let id: Int
        var offset: CGFloat
        let color: Color
    }
    
    @State var books = [
        Model(id: 0, offset: 0, color: Color.blue),
        Model(id: 1, offset: 0, color: Color.red),
        Model(id: 2, offset: 0, color: Color.purple),
        Model(id: 3, offset: 0, color: Color.yellow),
        Model(id: 4, offset: 0, color: Color.orange),
        Model(id: 5, offset: 0, color: Color.pink),
    ]
    
    @State var swiped = 0

    var body: some View{
        
        VStack{
            
            Spacer(minLength: 0)
            
            ZStack{

                ForEach(books.reversed(), id: \.id){book in

                    HStack{
                        ZStack{
                            Rectangle()
                                .foregroundColor(book.color)
                                .ignoresSafeArea()
                                .frame(width: width, height: getHeight(index: book.id))
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5)
                        }
                        .offset(x: book.id - swiped < 3 ? CGFloat(book.id - swiped) * 30 : 60)

                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal,20)
                    .offset(x: book.offset)
                    .gesture(DragGesture().onChanged({ (value) in
                        withAnimation{onScroll(value: value.translation.width, index: book.id)}
                    }).onEnded({ (value) in
                        withAnimation{onEnd(value: value.translation.width, index: book.id)}
                    }))
                }
            }
            .frame(height: height)
            Spacer(minLength: 0)
        }
        .background(Color.LL.background.ignoresSafeArea(.all, edges: .all))
    }
    
    func getHeight(index : Int)->CGFloat{
    
        return height - (index - swiped < 3 ? CGFloat(index - swiped) * 40 : 80)
    }
    
    func onScroll(value: CGFloat,index: Int){
        
        if value < 0{
            if index != books.last!.id{
                books[index].offset = value
            }
        }
        else{
            if index > 0{
                if books[index - 1].offset <= 20{
                    books[index - 1].offset = -(width + 40) + value
                }
            }
        }
    }
    
    func onEnd(value: CGFloat,index: Int){
    
        if value < 0{
            if -value > width / 2 && index != books.last!.id{
                books[index].offset = -(width + 100)
                swiped += 1
            }
            else{
                books[index].offset = 0
            }
        }
        else{
            if index > 0{
                if value > width / 2{
                    books[index - 1].offset = 0
                    swiped -= 1
                }
                else{
                    books[index - 1].offset = -(width + 100)
                }
            }
        }
    }
}


struct CardTest_Previews: PreviewProvider {
    static var previews: some View {
        CardTest()
    }
}
