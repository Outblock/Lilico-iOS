//
//  ExploreTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 29/8/2022.
//

import Foundation

extension ExploreTabScreen {
    struct ViewState {
        var isLoading: Bool = false
        var list: [DAppModel] = []
    }
    
    enum Action {
        case fetchList
    }
}

class ExploreTabViewModel: ViewModel {
    
    @Published
    var state: ExploreTabScreen.ViewState = .init()
    
    func trigger(_ input: ExploreTabScreen.Action) {
        switch input {
        case .fetchList:
            state.isLoading = true
            Task {
                do {
                    let buildNumber: FirebaseDAppBuildNumber = try await FirebaseConfig.dappBuildNumber.fetch(decoder: JSONDecoder())
                    let localNumber = Bundle.main.infoDictionary?["CFBundleVersion"]
                    print("buildNumber ==> \(buildNumber)")
                    print("localNumber ==> \(localNumber)")
                    guard let numberString = localNumber as? String, let number = Int(numberString) else {
                        return
                    }
                    
                    if number > buildNumber.build {
                        return
                    }
                    
                    let isTestnet = LocalUserDefaults.shared.flowNetwork == .testnet
                    let list: [DAppModel] = try await FirebaseConfig.dapp.fetch(decoder: JSONDecoder())
                    await MainActor.run {
                        state.list = isTestnet ? list.filter{ $0.testnetURL != nil } : list
                        state.isLoading = false
                    }
                } catch {
                    state.isLoading = false
//                    HUD.error(title: "Fetch dApp")
                }
            }
        }
    }
    
}
