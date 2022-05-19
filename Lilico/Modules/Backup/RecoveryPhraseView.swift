//
//  RecoveryPhraseView.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import SwiftUI

extension RecoveryPhraseView {
    struct ViewState {
        var dataSource: [WordListView.WordItem]
        var icloudLoading: Bool = false
    }

    enum Action {
        case icloudBackup
        case googleBackup
        case manualBackup
        case back
    }
}

struct RecoveryPhraseView: View {
//    @EnvironmentObject
//    var router: HomeCoordinator.Router

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    var btnBack: some View {
        Button {
            viewModel.trigger(.back)
//            router.popToRoot()
//            self.presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }

    @State
    var isBlur: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recovery")
                                .bold()
                                .foregroundColor(Color.LL.text)

                            Text("Phrase")
                                .bold()
                                .foregroundColor(Color.LL.orange)
                        }
                        .font(.LL.largeTitle)

                        Text("Write down or copy these words in the right order and save them somewhere safe.")
                            .font(.LL.body)
                            .foregroundColor(.LL.note)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()

                    VStack {
                        HStack {
                            Spacer()
                            WordListView(data: Array(viewModel.dataSource.prefix(6)))
                            Spacer()
                            WordListView(data: Array(viewModel.dataSource.suffix(from: 6)))
                            Spacer()
                        }

                        Text("Hide")
                            .padding(5)
                            .padding(.horizontal, 5)
                            .foregroundColor(.LL.background)
                            .font(.LL.body)
                            .background(.LL.note)
                            .cornerRadius(12)
                            .onTapGesture {
                                isBlur = true
                            }
                    }
                    .onTapGesture {
                        isBlur.toggle()
                    }
                    .blur(radius: isBlur ? 10 : 0)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(lineWidth: 0.5)
                            VStack(spacing: 10) {
                                Image(systemName: "eyes")
                                    .font(.largeTitle)
                                Text("Make sure you are in a private place !")
                                    .foregroundColor(.LL.note)
                                    .font(.LL.body)
                                    .fontWeight(.semibold)
                                Text("Reveal")
                                    .padding(5)
                                    .padding(.horizontal, 2)
                                    .foregroundColor(.LL.background)
                                    .font(.LL.body)
                                    .background(.LL.note)
                                    .cornerRadius(12)
                                    .padding(.top, 10)
                            }
                            .opacity(isBlur ? 1 : 0)
                            .foregroundColor(.LL.note)
                        }
                        .allowsHitTesting(false)
                    }
                    .animation(.linear(duration: 0.2), value: isBlur)
                    .padding(.vertical, 20)

                    VStack(spacing: 10) {
                        Text("Do not share your secret phrase!")
                            .font(.LL.caption)
                            .bold()
                        Text("If someone has your secret phrase, they will have full control of your wallet.")
                            .font(.LL.footnote)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .foregroundColor(.LL.warning2)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.LL.warning6)
                    }
                    .padding(.bottom)

                    VPrimaryButton(model: ButtonStyle.primary,
                                   state: viewModel.icloudLoading ? .loading : .enabled,
                                   action: {
                                       viewModel.trigger(.icloudBackup)
                                   }, title: "Backup to iCould")

                    VPrimaryButton(model: ButtonStyle.border,
                                   action: {
                                       viewModel.trigger(.googleBackup)
                                   }, title: "Backup to Google Drive")

                    VPrimaryButton(model: ButtonStyle.plain,
                                   action: {
                                       viewModel.trigger(.manualBackup)
                                   }, title: "Backup Manually")
                }
//                    .padding(.bottom)
            }
            .onAppear {
                overrideNavigationAppearance()
            }
            .padding(.horizontal, 30)
//            .navigationBarBackButtonHidden(true)
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct RecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseView(viewModel: RecoveryPhraseViewModel().toAnyViewModel())
    }
}

struct WordListView: View {
    struct WordItem: Identifiable {
        var id: Int
        let word: String
//        let index: Int
    }

    var data: [WordItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data) { item in
                HStack(spacing: 18) {
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .height(30)
                        .foregroundColor(.separator.opacity(0.3))
                        .overlay {
                            Text(String(item.id))
                                .font(.caption)
                                .foregroundColor(Color.LL.rebackground)
                                .padding(8)
                                .minimumScaleFactor(0.8)
                        }
                    Text(item.word)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}
