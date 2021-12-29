//
//  UsernameView.swift
//  Lilico
//
//  Created by Hao Fu on 26/12/21.
//

import SwiftUI
import SwiftUIX

struct UsernameView: View {
    
    @StateObject
    var viewModel: AnyViewModel<UsernameViewState, UsernameViewAction>
    
    @State
    var text: String = ""
    
    @State
    var textStatus: LL.TextField.Status = .normal
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Pick Your")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    Text("Username")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                    Text("Other Lilico users can find you and send you payments via your unique username.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                LL.TextField(placeHolder: "Username",
                             text: $text,
                             status: $textStatus,
                             onEditingChanged: { isEditing in
                    if isEditing {
                        viewModel.trigger(.onEditingChanged(text))
                    }
                })
                .padding(.bottom)

                
                Button {
                    
                } label: {
                    Text("Next")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity,alignment: .center)
                        .padding(.vertical, 18)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundColor(Color.LL.rebackground)
                                
                        }
                }
            }
                .padding(.horizontal, 30)
//                .padding(.bottom)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: btnBack)
        }
        
    }
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
    }
}
