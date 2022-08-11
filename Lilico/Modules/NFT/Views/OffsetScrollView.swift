//
//  OffsetScrollView.swift
//  Sky
//
//  Created by cat on 2022/6/1.
//

import SwiftUI

private let RefreshOffset: CGFloat = 70

struct OffsetScrollView<Content: View>: View {
    @Binding var offset: CGFloat
    
    let refreshEnabled: Bool
    let loadMoreEnabled: Bool

    /// Note: it will call multiple times, so you need guard it yourself.
    let refreshCallback: (() -> ())?
    
    /// Note: it will call multiple times, so you need guard it yourself.
    let loadMoreCallback: (() -> ())?
    let isNoData: Bool
    
    let content: Content

    init(offset: Binding<CGFloat>, refreshEnabled: Bool = false, loadMoreEnabled: Bool = false, refreshCallback: (() -> ())? = nil, loadMoreCallback: (() -> ())? = nil, isNoData: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.refreshEnabled = refreshEnabled
        self.refreshCallback = refreshCallback
        self.loadMoreEnabled = loadMoreEnabled
        self.loadMoreCallback = loadMoreCallback
        self.isNoData = isNoData
        _offset = offset
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: NavigationScrollPreferenKey.self,
                                    value: geo.frame(in: .named("ScrollView")).minY)
                }
                .frame(width: 0, height: 0)
                
                LazyVStack(spacing: 0) {
                    content
                    if loadMoreEnabled {
                        loadMoreView
                            .onAppear {
                                debugPrint("trigger a load more")
                                
                                if isNoData {
                                    debugPrint("trigger a load more - no data")
                                    return
                                }
                                
                                debugPrint("trigger a load more - sent")
                                DispatchQueue.main.async {
                                    loadMoreCallback?()
                                }
                            }
                    }
                }
            }
            .frame(alignment: .top)
            .coordinateSpace(name: "ScrollView")
            .onPreferenceChange(NavigationScrollPreferenKey.self) { value in
                self.offset = value
                
                if value > RefreshOffset, refreshEnabled {
                    DispatchQueue.main.async {
                        refreshCallback?()
                    }
                }
            }
            
            if refreshEnabled {
                refreshView
                    .opacity(refreshOpacity)
            }
        }
    }
    
    var refreshOpacity: CGFloat {
        if offset < 0 {
            return 0
        }
        
        let percent = abs(offset / RefreshOffset)
        return max(0, min(1, percent))
    }
    
    var refreshView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, UIView.topSafeAreaHeight + 44)
    }
    
    var loadMoreView: some View {
        VStack {
            Text(isNoData ? "no_more_data".localized : "loading".localized)
                .font(.inter(size: 14))
                .foregroundColor(Color.LL.Neutrals.note)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
    }
}

private class NavigationScrollPreferenKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
}

struct NavigationScrollView_Previews: PreviewProvider {
    static var previews: some View {
        OffsetScrollView(offset: .constant(1)) {
            LazyVStack {
                ForEach(0 ..< 200) { index in
                    Text("Row number \(index)")
                        .padding()
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
