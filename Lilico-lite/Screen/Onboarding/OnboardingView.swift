//
//  OnboardingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI
import SwiftUIX

struct OnboardingView: View {
    @State var offset: CGFloat = 0

    @State var gotoWallet: String? = ""
    @EnvironmentObject
    private var viewModel: AnyViewModel<OnboardingState, OnboardingAction>

    
    // offset for indicator...
    var indicatorOffset: CGFloat {
        let progress = offset / screenWidth
        // 12 = spacing
        // 7 = Circle size...
        let maxWidth: CGFloat = 12 + 7
        return progress * maxWidth
    }

    var currentIndex:Int {
        let progress = round(offset / screenWidth)
        // For Saftey...
        let index = min(Int(progress), viewModel.intros.count - 1)
        return index
    }

    var rotation: Double {
        let progress = offset / (screenWidth * 4)
        let rotation = Double(progress) * 360
        return rotation
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    OffsetPageTabView(offset: $offset) {
                        HStack(spacing: 0) {
                            ForEach(viewModel.intros) { intro in

                                VStack {
                                    Image(intro.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: screenHeight / 2)

                                    VStack(alignment: .leading, spacing: 22) {
                                        Text(intro.title)
                                            .foregroundColor(.primary)
                                            .font(.largeTitle.bold())

                                        Text(intro.description)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.top, 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                // setitng max Width..
                                .frame(width: screenWidth)
                            }
                        }
                    }

                    // Animated Indicator....
                    HStack {
                        // Indicators...
                        PageIndictor(indicatorOffset: indicatorOffset,
                                     currentIndex: currentIndex,
                                     count: viewModel.intros.count)

                        Spacer()

                        NavigationLink(destination: WalletSetupView(),
                                       tag: "A",
                                       selection: $gotoWallet) { EmptyView() }
                                       .navigationBarHidden(true)
                        
                        Button {
                            
                            // last page
                            if currentIndex == (viewModel.intros.count-1) {
//                                viewModel.trigger(.finish)
                                gotoWallet = "A"
                            }
                            
                            // updating offset...
                            let index = min(currentIndex + 1, viewModel.intros.count - 1)
                            offset = CGFloat(index) * screenWidth
                            
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(25)
                                .background(
                                    viewModel.intros[currentIndex].color,
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
                        .fill(viewModel.intros[currentIndex].rectColor)
                        // Size as image size...
                        .frame(width: screenWidth * 0.8,
                               height: screenWidth * 0.9)
                        .scaleEffect(2)
                        .rotationEffect(.init(degrees: 25))
                        .rotationEffect(.init(degrees: rotation))
                        .offset(y: -screenWidth + 20),

                    alignment: .leading
                )
                .background(Color.LL.background.edgesIgnoringSafeArea(.all))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                // Animating when index Changes...
                .animation(.easeInOut, value: currentIndex)
            }
            SmallButton(text: "Skip") {
                viewModel.trigger(.skip)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(
                AnyViewModel(
                    OnboardingViewModel()
                )
            )
            .colorScheme(.dark)
    }
}

struct SmallButton: View {
    let text: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
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
