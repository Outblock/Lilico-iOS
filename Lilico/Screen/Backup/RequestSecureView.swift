//
//  RequestSecureView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI

extension RequestSecureView {
    enum ViewState {
        //        var isLoading = false
//        var dataSource: [BackupModel]
        case initScreen
    }

    enum Action {}
}

struct RequestSecureView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

//    @StateObject
//    var viewModel: AnyViewModel<ViewState, Action>

    var btnBack: some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }

    var model: VPrimaryButtonModel = {
        var model = ButtonStyle.border
//        model.colors.border = .init(enabled: Color.LL.rebackground.opacity(0.5),
//                                    pressed: Color.LL.rebackground.opacity(0.2),
//                                    loading: Color.LL.rebackground.opacity(0.5),
//                                    disabled: Color.LL.rebackground.opacity(0.5))
        model.layout.height = 64
        return model
    }()

    var pinModel: VPrimaryButtonModel = {
        var model = ButtonStyle.primary
//        model.colors.border = .init(enabled: Color.LL.rebackground.opacity(0.5),
//                                    pressed: Color.LL.rebackground.opacity(0.2),
//                                    loading: Color.LL.rebackground.opacity(0.5),
//                                    disabled: Color.LL.rebackground.opacity(0.5))
        model.layout.height = 64
        return model
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Add Extra")
                        .bold()
                        .font(.largeTitle)

                    HStack {
                        Text("Protection")
                            .bold()
                            .foregroundColor(Color.LL.orange)

                        Text("to")
                            .bold()
                            .foregroundColor(Color.LL.rebackground)
                    }
                    .font(.largeTitle)

                    Text("Your Wallet")
                        .bold()
                        .font(.largeTitle)

                    Text("Please select the word one by one refering to its order.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                Spacer()

                VPrimaryButton(model: pinModel) {} content: {
                    HStack(spacing: 15) {
                        Image(systemName: "faceid")
                            .font(.title2)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 30, alignment: .leading)
//                            .foregroundColor(Color.LL.orange)
                        VStack(alignment: .leading) {
                            Text("Face ID")
                            Text("Recommend")
                                .foregroundColor(Color.LL.orange)
                                .font(.footnote)
                        }
                        Spacer()
                        Image(systemName: "arrow.forward.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 18)
                    .foregroundColor(Color.LL.background)
                }

                VPrimaryButton(model: model) {} content: {
                    HStack(spacing: 15) {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
//                            .font(.title2)
//                            .foregroundColor(Color.LL.orange)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, alignment: .leading)
                        Text("Pincode ID")
                        Spacer()
                        Image(systemName: "arrow.forward.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 18)
                    .foregroundColor(Color.LL.rebackground)
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .onAppear {}
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    HStack {
//                        Image(systemName: "sun.min.fill")
//                        Text("Title").font(.headline)
//                    }
//                }
//            }
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct RequestSecureView_Previews: PreviewProvider {
    static var previews: some View {
        RequestSecureView()
//            .colorScheme(.dark)
    }
}
