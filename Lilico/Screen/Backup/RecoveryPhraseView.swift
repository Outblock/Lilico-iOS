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
    }
}

struct RecoveryPhraseView: View {
    @EnvironmentObject
    var router: RegisterCoordinator.Router

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    var btnBack: some View {
        Button {
//            router.pop()
            self.presentationMode.wrappedValue.dismiss()
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
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recovery")
                                .bold()
                                .foregroundColor(Color.LL.rebackground)

                            Text("Phrase")
                                .bold()
                                .foregroundColor(Color.LL.orange)
                        }
                        .font(.largeTitle)

                        Text("Write down or copy these words in the right order and save them somewhere safe.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()

                    HStack {
                        WordListView(data: Array(viewModel.dataSource.prefix(6)))
                        WordListView(data: Array(viewModel.dataSource.suffix(from: 6)))
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(lineWidth: 0.5)
                    }
                    .padding(.vertical, 20)

                    VStack(spacing: 10) {
                        Text("Do not share your secret phrase!")
                            .font(.caption)
                            .bold()
                        Text("If someone has your secret phrase, they will have full control of your wallet.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .foregroundColor(.red)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.red.opacity(0.1))
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
        VStack(alignment: .leading, spacing: 18) {
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
