//
//  WalletSetupView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI
import SwiftUIX

struct WalletSetupView: View {
    
    @State var show = false
    
    @State var goHome: String? = ""
    
    @EnvironmentObject
    private var viewModel: AnyViewModel<WalletSetupState, WalletSetupAction>
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack(alignment: .center) {
                    Spacer()
                    Image("06")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
    //                    .frame(width: screenWidth)
                    
                    Text("Welcome ")
                        .foregroundColor(Color.LL.rebackground)
                        .padding()
                        .font(.largeTitle, weight: .bold)
                    VStack(alignment: .center, spacing: 15) {
                        LongButton(text: "Create a new wallet",
                                   color: Color.LL.orange,
                                   iconName: "plus.circle.fill") {
                            self.show = false
                        }
                        
                        LongButton(text: "Import a wallet",
                                   color: Color(hex:"FFcf4e"),
                                   iconName: "arrow.uturn.down.circle.fill") {
                            self.show = true
                        }
                        .onAppear {
                            self.show = true
                        }
                        
                        NavigationLink(destination: HomeView(),
                                       tag: "A",
                                       selection: $goHome) { EmptyView() }
                                       .navigationBarHidden(true)
                        
                        Button{
                            goHome = "A"
                        } label: {
                            HStack {
                                Text("Not already yet? Import flow address ")
                                    .font(.subheadline)
                                    .lineLimit(nil)
                                    .foregroundColor(Color.LL.rebackground)
                                    .padding(5)
                                    .padding(.horizontal)
        //                            .background(Color.link)
                                    .cornerRadius(10)
                                    .padding()
                                
                                Image(systemName: "chevron.forward.circle.fill")
                                    .foregroundColor(Color.LL.orange)
                            }
                        }
                        

    //                    Spacer()
    //                    Divider().frame(height: 5)
    //                        .foregroundColor(Color.LL.rebackground.opacity(0.8))
    //
    //                    Text("Already have a **key?**")
    //                        .font(.footnote)
    //
    //                    HStack(alignment: .center, spacing: 20) {
    //                        Spacer()
    //                        Button {} label: {
    //                            ImageBook.googleDrive
    //                                .renderingMode(.original)
    //                                .resizable()
    //                                .frame(maxWidth: 35, maxHeight: 35)
    //                                .padding(15)
    //                                .background(
    //                                    Color.LL.rebackground.opacity(0.1),
    //                                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
    //                                )
    //                        }.aspectRatio(1, contentMode: .fit)
    //
    //                        Button {} label: {
    //                            ImageBook.icloud
    //                                .renderingMode(.original)
    //                                .resizable()
    //                                .frame(maxWidth: 35, maxHeight: 35)
    //                                .padding(15)
    //                                .background(
    //                                    Color.LL.rebackground.opacity(0.1),
    //                                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
    //                                )
    //                        }.aspectRatio(1, contentMode: .fit)
    //                        Spacer()
    //                    }
                    }.padding()
    //                    .frame(height: screenHeight * 0.5)
                        .padding(.bottom, 30)
                        .background(Color.LL.background.edgesIgnoringSafeArea(.all))
                        .cornerRadius([.topRight, .topLeft], 30)

                }
                .frame(screenBounds.size)
                .ignoresSafeArea()
            }
//            .background{
//                ZStack {
//                    Image(uiImage: #imageLiteral(resourceName: "Blob"))
//                        .offset(x: -0, y: -100)
//                        .rotationEffect(Angle(degrees: show ? 360 + 90 : 90))
//                        .blendMode(.normal)
//                        .animation(Animation.linear(duration: 120).repeatForever(autoreverses: false),
//                                   value: show)
//                        //                    .animation(nil)
//                        .onAppear {
//                            self.show = false
//                        }
//
//                    Image(uiImage: #imageLiteral(resourceName: "Blob"))
//                        .offset(x: -30, y: -300)
//                        .rotationEffect(Angle(degrees: show ? 360 : 0), anchor: .leading)
//                        .blendMode(.overlay)
//                        .animation(Animation.linear(duration: 120).repeatForever(autoreverses: false))
//                }
//            }
            .background(Color.LL.background.edgesIgnoringSafeArea(.all))
        } .navigationBarHidden(true)
            .hideNavigationBar()
    }
}

struct WalletSetupView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSetupView().colorScheme(.dark)
            .environmentObject(
                AnyViewModel(
                    WalletSetupViewModel()
                )
            )
        WalletSetupView()
    }
}

struct OutlineModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    .linearGradient(
                        colors: [
                            .white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                            .black.opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct LongButton: View {
    var text: String
    var color: Color = Color(hex: "#2F2E39")
    var iconName: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: iconName)
                Text(text)
            }
            .font(.body)
            .foregroundColor(.white)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .foregroundColor(Color.LL.rebackground)
        .background(
            color,
            in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
        )
    }
}
