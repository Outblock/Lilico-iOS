//
//  ChooseAccount.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

struct ChooseAccountView: View {
    @EnvironmentObject
    var router: RegisterCoordinator.Router
    
    var btnBack : some View {
        Button{
            router.dismissCoordinator()
        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Choose")
                            .foregroundColor(Color.LL.rebackground)
                            .bold()
                        Text("Account")
                            .foregroundColor(Color.LL.orange)
                            .bold()
                    }
                    .font(.largeTitle)
                    
                    Text("Multiple accouns found.")
                        .font(.body)
                        .bold()
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button {
                    router.route(to: \.userName)
                } label: {
                    HStack {
                        Text("Username")
                            .font(.headline)
                            .bold()
                            .frame(maxWidth: .infinity,alignment: .center)
                            
                        Image(systemName: "chevron.right")
                            .padding(.trailing)
                    }
                    .padding(.vertical, 18)
                    .foregroundColor(Color.LL.rebackground)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(.separator)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
        }
    }

}

struct ChooseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseAccountView()
    }
}
