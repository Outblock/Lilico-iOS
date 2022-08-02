//
//  RequestView.swift
//  Lilico
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import SwiftUI
import WalletConnectSign

struct RequestView: View {
    
    let request: RequestInfo
    
    let approve: (() -> Void)?
    let reject: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(
                url: URL(string: request.iconURL),
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
            
            Text(request.name).font(.title).bold()
            Text(request.dappURL).font(.body).foregroundColor(.secondary)
//            Text(request.descriptionText).font(.body).foregroundColor(.gray)
//            Text(request.data).font(.body).foregroundColor(.gray)
            
//            Label("flow", image: "flow-logo")
            
            List {
                
                if let args = try? request.agrument.jsonPrettyPrinted() {
                    Section("Argument") {
                        Text(args).font(.body).foregroundColor(.gray)
                    }.headerProminence(.increased)
                }
                
                Section("Script") {
                    Text(request.cadence).font(.body).foregroundColor(.gray)
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
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView(request: RequestInfo(
            cadence: "13121232",
            agrument: [.init(value: .string("12321"))],
            name: "Test",
                                         descriptionText: "descriptionText",
                                         dappURL: "https://test.com",
                                         iconURL: "https://github.com/Outblock/Assets/blob/main/ft/flow/logo.png?raw=true",
                                         chains: Set([Blockchain("flow:tetsnet")!]),
                                         methods: ["method_1", "method_2"],
                                         pendingRequests: ["1321"],
                                        message: ""),
                    approve: nil,
                    reject: nil
        )
    }
}
