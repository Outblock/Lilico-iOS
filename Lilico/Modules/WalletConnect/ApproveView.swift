//
//  ApproveView.swift
//  Lilico
//
//  Created by Hao Fu on 30/7/2022.
//

import SwiftUI
import WalletConnectSign

struct ApproveView: RouteableView {
    
    var title: String {
        return "Approve"
    }
    
    func backButtonAction() {
        reject?()
    }
    
    let session: SessionInfo
    
    let approve: (() -> Void)?
    let reject: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(
                url: URL(string: session.iconURL),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 80, maxHeight: 80)
                },
                placeholder: {
                    ProgressView()
                }
            )
            .padding(.top, 40)
            
            Text(session.name).font(.title).bold()
            Text(session.dappURL).font(.body).foregroundColor(.secondary)
            Text(session.descriptionText).font(.body).foregroundColor(.gray)
            Text(session.data).font(.body).foregroundColor(.gray)
            
            Label("flow", image: "flow-logo")
            
            List {
                
                if let chain = session.chains?.first {
                    Section("Network") {
                        Text(chain.reference).font(.body).foregroundColor(.gray)
                    }.headerProminence(.increased)
                }
                
                Section("Methods") {
                    ForEach(Array(session.methods ?? []), id: \.hashValue) { method in
                        Text(method).font(.body).foregroundColor(.gray)
                    }
                }.headerProminence(.increased)
            }
            
            Spacer()
            HStack(alignment: .center, spacing: 12) {
                Button {
                    reject?()
                } label: {
                    Label("Reject", systemImage: "xmark.app.fill")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.red)
                .cornerRadius(12)
                
                
                Button {
                    approve?()
                } label: {
                    Label("Approve", systemImage: "checkmark.square.fill")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .interactiveDismissDisabled()
    }
}

struct ApproveView_Previews: PreviewProvider {
    static var previews: some View {
        
        let session = SessionInfo(name: "Test",
                                  descriptionText: "descriptionText",
                                  dappURL: "https://test.com",
                                  iconURL: "https://github.com/Outblock/Assets/blob/main/ft/flow/logo.png?raw=true",
                                  chains: Set([Blockchain("flow:tetsnet")!]),
                                  methods: ["method_1", "method_2"],
                                  pendingRequests: ["1321"],
                                 data: "")
        
        ApproveView(session: session,
                    approve: nil,
                    reject: nil
        )
    }
}
