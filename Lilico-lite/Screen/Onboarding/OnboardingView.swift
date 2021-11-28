//
//  OnboardingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI
import SwiftUIX

struct Intro: Identifiable{
    var id = UUID().uuidString
    var image: String
    var title: String
    var description: String
    var color: Color
    var rectColor: Color
}

struct OnboardingView: View {
    
    @State var offset: CGFloat = 0
    
    var intros : [Intro] = [
        Intro(image: "Onboarding_1",
              title: "Secure your funds",
              description: "But they are not the inconvenience that our pleasure.",
              color: Color.LL.primary,
              rectColor: Color(hex: "#FFCF4E")),
        Intro(image: "Onboarding_2",
              title: "Manage your crypto asset",
              description: "There is no provision to smooth the consequences are.",
              color: Color.LL.primary,
              rectColor: Color(hex: "#FF81B4")),
        Intro(image: "Onboarding_3",
              title: "Show your NFTs",
              description: "ter than the pain of the soul to the task.",
              color: Color.LL.primary,
              rectColor: Color(hex: "#00ACFB")),
    ]
    
    var body: some View {
        
        GeometryReader{proxy in
            
            ZStack {
                VStack{
                    
                    OffsetPageTabView(offset: $offset) {
                        
                        HStack(spacing: 0){
                            
                            ForEach(intros){intro in
                                
                                VStack{
                                    Image(intro.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: screenBounds().height / 2)
                                    
                                    VStack(alignment: .leading, spacing: 22) {
                                        
                                        Text(intro.title)
                                            .foregroundColor(.primary)
                                            .font(.largeTitle.bold())
                                        
                                        Text(intro.description)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.top,50)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                }
                                .padding()
                                // setitng max Width..
                                .frame(width: screenBounds().width)
                            }
                        }
                        //                .background(Color.backgroundX)
                    }
                    
                    // Animated Indicator....
                    HStack() {
                        
                        // Indicators...
                        HStack(spacing: 12){
                            
                            ForEach(intros.indices,id: \.self){index in
                                
                                Capsule()
                                    .fill(getIndex() == index ? .yellow : .primary)
                                // increasing width for only current index...
                                    .frame(width: getIndex() == index ? 20 : 7, height: 7)
                            }
                        }
                        .overlay(
                            
                            Capsule()
                                .fill(.yellow)
                                .frame(width: 20, height: 7)
                                .offset(x: getIndicatorOffset())
                            
                            ,alignment: .leading
                        )
                        
                        Spacer()
                        
                        Button {
                            
                            // updating offset...
                            let index = min(getIndex() + 1, intros.count - 1)
                            offset = CGFloat(index) * screenBounds().width
                            
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(25)
                                .background(
                                    intros[getIndex()].color,
                                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                )
                        }
                        
                    }
                    .padding()
                    .offset(y: -20)
                    
                }
                // Animation...
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(intros[getIndex()].rectColor)
                    // Size as image size...
                        .frame(width: screenBounds().width*0.8,
                               height: screenBounds().width * 0.9)
                        .scaleEffect(2)
                        .rotationEffect(.init(degrees: 25))
                        .rotationEffect(.init(degrees: getRotation()))
                        .offset(y: -screenBounds().width + 20)

                    ,alignment: .leading
                )
                .background(Color.LL.background.edgesIgnoringSafeArea(.all))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                // Animating when index Changes...
                .animation(.easeInOut,value: getIndex())
            }
            SkipButton()
        }
    }
    
    // offset for indicator...
    func getIndicatorOffset()->CGFloat{
        let progress = offset / screenBounds().width
        // 12 = spacing
        // 7 = Circle size...
        let maxWidth: CGFloat = 12 + 7
        return progress * maxWidth
    }
    
    // Expading index based on offset...
    func getIndex()->Int{
        let progress = round(offset / screenBounds().width)
        // For Saftey...
        let index = min(Int(progress), intros.count - 1)
        return index
    }
    
    // getting Rotation...
    func getRotation()->Double{
        
        let progress = offset / (screenBounds().width * 4)
        
        // Doing one full rotation...
        let rotation = Double(progress) * 360
        
        return rotation
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView().colorScheme(.dark)
    }
}

struct SkipButton: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Skip")
                .dynamicTypeSize(.xSmall)
                .foregroundColor(Color.LL.background)
                .padding(8)
                .background(
                    Color.primary.opacity(0.3),
                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                )
            
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
}
