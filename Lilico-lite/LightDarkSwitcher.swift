//
//  LightDarkSwitcher.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI

struct LightSwitchView: View {
    // MARK: - variables

    let appWidth = UIScreen.main.bounds.width
    let appHeight = UIScreen.main.bounds.height
    let animationDuration: TimeInterval = 0.35

    @State var xScale: CGFloat = 2
    @State var yScale: CGFloat = 0.4
    @State var yOffset: CGFloat = UIScreen.main.bounds.height * 0.8

    @State var isOff: Bool = true

    // MARK: - views

    var body: some View {
        ZStack {
            Color.black
            Circle()
                .fill(Color.yellow)
                .scaleEffect(CGSize(width: xScale, height: yScale))
                .offset(y: yOffset)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(isOff ? .white : .black)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    Spacer()

                        .offset(x: -12)
                    Spacer()
                }.padding([.top, .bottom], 24)
                Spacer()
            }.offset(y: 32)
                .padding([.leading, .trailing], 24)
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(.gray)
                    .frame(width: 52, height: appHeight * 0.25 + 6)
                    .opacity(0.275)
                    .offset(x: appWidth / 2 - 48, y: 16)
                ZStack {
                    Capsule()
                        .frame(width: 3, height: self.isOff ? appHeight * 0.41 : appHeight * 0.625)
                        .foregroundColor(.white)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 42, height: 42)
                        .offset(y: self.isOff ? appHeight * 0.225 : appHeight * 0.25 + 42)
                        .onTapGesture {
                            toggleAllLights()
                        }
                }.offset(x: appWidth / 2 - 48, y: -appHeight / 2)
                    .frame(height: 0, alignment: .top)
            }
            .animation(Animation.spring(dampingFraction: 0.65).speed(1.25))
        }.edgesIgnoringSafeArea(.all)
    }

    // MARK: - functions

    func toggleAllLights() {
        if isOff {
            withAnimation(Animation.easeIn(duration: animationDuration)) {
                xScale = 4
                yScale = 4
                yOffset = 0
            }
        } else {
            withAnimation(Animation.easeOut(duration: animationDuration * 0.75)) {
                yScale = 0.4
                xScale = 2
                yOffset = UIScreen.main.bounds.height * 0.8
            }
        }
        isOff.toggle()
    }
}

struct LightSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        LightSwitchView()
//        CoverView()
    }
}

struct CoverView: View {
    @State var show = false
    @State var viewState = CGSize.zero
    @State var isDragging = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                Text("Learn design & code.\nFrom scratch.")
                    .font(.system(size: geometry.size.width / 10, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 375, maxHeight: 100)
            .padding(.horizontal, 16)
            .offset(x: viewState.width / 15, y: viewState.height / 15)

            Text("80 hours of courses for SwiftUI, React and design tools.")
                .font(.subheadline)
                .frame(width: 250)
                .offset(x: viewState.width / 20, y: viewState.height / 20)

            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 100)
        .frame(height: 477)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Image(uiImage: #imageLiteral(resourceName: "Blob"))
                    .offset(x: -150, y: -200)
                    .rotationEffect(Angle(degrees: show ? 360 + 90 : 90))
                    .blendMode(.plusDarker)
                    .animation(Animation.linear(duration: 120).repeatForever(autoreverses: false))
                    //                    .animation(nil)
                    .onAppear { self.show = true }

                Image(uiImage: #imageLiteral(resourceName: "Blob"))
                    .offset(x: -200, y: -250)
                    .rotationEffect(Angle(degrees: show ? 360 : 0), anchor: .leading)
                    .blendMode(.overlay)
                    .animation(Animation.linear(duration: 120).repeatForever(autoreverses: false))
                //                    .animation(nil)
            }
        )
        .background(
            Image(uiImage: #imageLiteral(resourceName: "Card3"))
                .offset(x: viewState.width / 25, y: viewState.height / 25),
            alignment: .bottom
        )
        .background(Color(#colorLiteral(red: 0.4117647059, green: 0.4705882353, blue: 0.9725490196, alpha: 1)))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .scaleEffect(isDragging ? 0.9 : 1)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
        .rotation3DEffect(Angle(degrees: 5), axis: (x: viewState.width, y: viewState.height, z: 0))
        .gesture(
            DragGesture().onChanged { value in
                self.viewState = value.translation
                self.isDragging = true
            }
            .onEnded { _ in
                self.viewState = .zero
                self.isDragging = false
            }
        )
    }
}
