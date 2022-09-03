//
//  NFTDetailPage.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import Kingfisher
import SwiftUI

class NFTDetailPageViewModel: ObservableObject {
    @Published var nft: NFTModel
    @Published var svgString: String = ""
    
    init(nft: NFTModel) {
        self.nft = nft
        
        if nft.isSVG {
            guard let rawSVGURL = nft.response.postMedia.image, let rawSVGURL = URL(string: rawSVGURL) else {
                return
            }
            
            Task {
                if let svg = await SVGCache.cache.getSVG(rawSVGURL) {
                    DispatchQueue.main.async {
                        self.svgString = svg
                    }
                }
            }
        }
    }
    
    func sendNFTAction() {
        Router.route(to: RouteMap.AddressBook.pick({ [weak self] contact in
            Router.dismiss(animated: true) {
                guard let self = self else {
                    return
                }
                Router.route(to: RouteMap.NFT.send(self.nft, contact))
            }
        }))
    }
}

struct NFTDetailPage: RouteableView {
    static var ShareNFTView: NFTShareView? = nil
    
    var title: String {
        return ""
    }
    
    var isNavigationBarHidden: Bool {
        return true
    }

    @StateObject
    var viewModel: NFTTabViewModel

    @StateObject
    var vm: NFTDetailPageViewModel
    
    
    @State var opacity: Double = 0

    var theColor: Color {
        if let color = viewModel.state.colorsMap[vm.nft.image.absoluteString]?[safe: 1] {
            return color.adjustbyTheme()
        }
        return Color.LL.Primary.salmonPrimary
    }

    @State
    private var isSharePresented: Bool = false

    @State
    private var isFavorited: Bool = false

    @State
    private var items: [UIImage] = []

    @State var image: Image?
    @State var rect: CGRect = .zero
    
    init(viewModel: NFTTabViewModel, nft: NFTModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _vm = StateObject(wrappedValue: NFTDetailPageViewModel(nft: nft))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            OffsetScrollViewWithAppBar(title: vm.nft.title) {
                Spacer()
                    .frame(height: 64)
                VStack(alignment: .leading) {
                    VStack(spacing: 0) {
                        if vm.nft.isSVG {
                            SVGWebView(svg: vm.svgString)
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .padding(.horizontal, 18)
                        } else {
                            KFImage
                                .url(vm.nft.image)
                                .placeholder({
                                    Image("placeholder")
                                        .resizable()
                                })
                                .onSuccess { _ in
                                    fetchColor()
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(alignment: .center)
                                .cornerRadius(8)
                                .padding(.horizontal, 18)
                                .clipped()
                        }

                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(vm.nft.title)
                                    .font(.LL.largeTitle3)
                                    .fontWeight(.w700)
                                    .foregroundColor(.LL.Neutrals.text)
                                    .frame(height: 28)
                                HStack(alignment: .center, spacing: 6) {
                                    KFImage
                                        .url(vm.nft.logoUrl)
                                        .placeholder({
                                            Image("placeholder")
                                                .resizable()
                                        })
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .cornerRadius(20)
                                        .clipped()
                                    Text(vm.nft.subtitle)
                                        .font(.LL.body)
                                        .fontWeight(.w400)
                                        .lineLimit(1)
                                        .foregroundColor(.LL.Neutrals.neutrals4)
                                }
                            }
                            Spacer()

                            Button {
                                share()
                            } label: {
                                Image("nft_button_share")
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(theColor)
                            }
                            .padding(.horizontal, 6)
                            .sheet(isPresented: $isSharePresented) {} content: {
                                ShareSheet(items: $items)
                            }

                            Button {
                                if NFTUIKitCache.cache.isFav(id: vm.nft.id) {
                                    NFTUIKitCache.cache.removeFav(id: vm.nft.id)
                                    isFavorited = false
                                } else {
                                    NFTUIKitCache.cache.addFav(nft: vm.nft)
                                    isFavorited = true
                                }
                            } label: {
                                ZStack(alignment: .center) {
                                    if isFavorited {
                                        Image("nft_logo_circle_fill")
                                        Image("nft_logo_star_fill")
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color.white)
                                    } else {
                                        Image("nft_logo_circle")
                                        Image("nft_logo_star")
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .foregroundColor(theColor)
                            }
                            .padding(.horizontal, 6)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 26)
                    }

                    //
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 18) {
                            if !vm.nft.tags.isEmpty {
                                NFTTagsView(tags: vm.nft.tags, color: theColor)
                            }

                            Text(vm.nft.declare)
                                .font(Font.inter(size: 14, weight: .w400))
                                .foregroundColor(.LL.Neutrals.neutrals6)
                        }
                        .padding(.horizontal, 26)
                        .padding(.vertical, 18)
                    }
                    .background(
                        Color.LL.Shades.front
                            .opacity(0.32)
                    )
                    .shadow(color: .LL.Shades.front, radius: 16, x: 0, y: 8)
                    .cornerRadius(16, corners: [.topLeft, .topRight])

                    Spacer()
                        .frame(height: 50)
                }

                image?
                    .resizable()
            } appBar: {
                BackAppBar {
                    viewModel.trigger(.back)
                }
            }
        }
        .background(
            NFTBlurImageView(colors: viewModel.state.colorsMap[vm.nft.image.absoluteString] ?? [])
                .ignoresSafeArea()
                .offset(y: -4)
        )
        .safeAreaInset(edge: .bottom, content: {
            HStack(spacing: 8) {
                Spacer()
                Button {
                    vm.sendNFTAction()
                } label: {
                    HStack {
                        Image(systemName: "paperplane")
                            .font(.system(size: 16))
                            .foregroundColor(theColor)
                        Text("send".localized)
                            .foregroundColor(.LL.Neutrals.text)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .cornerRadius(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: theColor.opacity(0.4), radius: 24, x: 0, y: 16)
                .visibility(vm.nft.isDomain ? .gone : .visible)

                Menu {
                    Button {} label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16))
                            .foregroundColor(theColor)
                        Text("download".localized)
                            .foregroundColor(.LL.Neutrals.text)
                    }

                    Button {} label: {
                        HStack {
                            Text("view_on_web".localized)
                                .foregroundColor(.LL.Neutrals.text)
                            Image(systemName: "globe.asia.australia")
                                .font(.system(size: 16))
                                .foregroundColor(theColor)
                        }
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(theColor)
                    Text("more".localized)
                        .foregroundColor(.LL.Neutrals.text)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .cornerRadius(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: theColor.opacity(0.4), radius: 24, x: 0, y: 20)
            }
            .padding(.trailing, 18)
        })
        .onAppear {
            isFavorited = NFTUIKitCache.cache.isFav(id: vm.nft.id)
        }
        .applyRouteable(self)
    }

    var date: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("purchase_price".localized)
                        .font(.LL.body)
                        .frame(height: 22)
                        .foregroundColor(.LL.Neutrals.neutrals7)
                    HStack(alignment: .center, spacing: 4) {
                        Image("Flow")
                            .resizable()
                            .frame(width: 12, height: 12)
                        Text("1,289.20")
                            .font(Font.W700(size: 16))
                            .foregroundColor(.LL.Neutrals.text)
                            .frame(height: 24)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("purchase_date".localized)
                        .font(.LL.body)
                        .frame(height: 22)
                        .foregroundColor(.LL.Neutrals.neutrals7)
                    Text("2022.01.22")
                        .font(Font.W700(size: 16))
                        .foregroundColor(.LL.Neutrals.text)
                        .frame(height: 24)
                }
            }
            .padding(0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
    }

    func fetchColor() {
        viewModel.trigger(.fetchColors(vm.nft.image.absoluteString))
    }

    static var retryCount: Int = 0
    func share() {
        if let colors = viewModel.state.colorsMap[vm.nft.image.absoluteString] {
            NFTDetailPage.ShareNFTView = NFTShareView(nft: vm.nft, colors: colors)
            let img = NFTDetailPage.ShareNFTView.snapshot()
            image = Image(uiImage: img)
            NFTDetailPage.ShareNFTView = nil
        } else {
            NFTDetailPage.retryCount += 1
            if NFTDetailPage.retryCount < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    share()
                }
            } else {
                NFTDetailPage.retryCount = 0
                // TODO: share error
            }
        }
    }
}

struct NFTDetailPage_Previews: PreviewProvider {
    static var nft = NFTTabViewModel.testNFT()
    static var previews: some View {
        NFTDetailPage(viewModel: NFTTabViewModel(), nft: nft)
    }
}
