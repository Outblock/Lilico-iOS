//
//  NavigationDemo.swift
//  Lilico
//
//  Created by Hao Fu on 5/1/22.
//

import SwiftUI

struct NavigationDemo: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(1 ..< 30) { _ in
                        NavigationLink("Hello") {
                            NavigationDetailDemo()
                        }
                    }
                }
            }
            .navigationViewStyle(.automatic)
            .navigationTitle("测试")
            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarHidden(true)
        }
        .onAppear {
            overrideNavigationAppearance()
        }
    }
}

extension NavigationDemo {}

func overrideNavigationAppearance() {
    // 设置样式 iOS 15生效
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithOpaqueBackground()
    coloredAppearance.backgroundColor = .clear
    coloredAppearance.shadowColor = .clear
    let titleAttributed: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.clear,
    ]

    coloredAppearance.titleTextAttributes = titleAttributed

    let backButtonAppearance = UIBarButtonItemAppearance()
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    coloredAppearance.backButtonAppearance = backButtonAppearance

    let backImage = UIImage(systemName: "arrow.backward")
    coloredAppearance.setBackIndicatorImage(backImage,
                                            transitionMaskImage: backImage)
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
}

struct NavigationDemo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDemo()
    }
}
