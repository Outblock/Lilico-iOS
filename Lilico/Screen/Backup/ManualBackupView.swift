//
//  ManualBackupView.swift
//  Lilico
//
//  Created by Hao Fu on 4/1/22.
//

import SwiftUI

extension ManualBackupView {
    enum ViewState {
        //        var isLoading = false
//        var dataSource: [BackupModel]
        case initScreen
        case render(dataSource: [BackupModel])
    }

    enum Action {
        case loadDataSource
        case backupSuccess
    }
}

struct ManualBackupView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    struct BackupModel: Identifiable {
        let id = UUID()
        let position: Int
        let correct: Int
        let list: [String]
    }

    var mockData: [BackupModel] = [
        .init(position: 2, correct: 1, list: ["Abstract", "Apple", "Alience"]),
        .init(position: 4, correct: 0, list: ["Food", "First", "Fire"]),
        .init(position: 8, correct: 2, list: ["Loop", "Lilico", "Libra"]),
        .init(position: 10, correct: 0, list: ["Zip", "Zion", "Zoo"]),
    ]

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

    @State
    var selectArray: [Int?] = [nil, nil, nil, nil]

    var isAllPass: Bool {
        if case let .render(dataSource) = viewModel.state {
            return dataSource.map { $0.correct } == selectArray
        }
        return false
    }

    var model: VSegmentedPickerModel = {
        var model = VSegmentedPickerModel()
        model.layout.height = 64
        model.layout.cornerRadius = 16
        model.layout.indicatorCornerRadius = 16
        model.layout.indicatorMargin = 8
        model.layout.headerFooterSpacing = 8
        return model
    }()

    func getColor(selectIndex: Int?,
                  item: String,
                  list: [String],
                  currentListIndex _: Int,
                  correct: Int) -> Color
    {
        guard let selectIndex = selectIndex else {
            return .gray
        }

        guard let index = list.firstIndex(of: item), selectIndex == index else {
            return .gray
        }

        return selectIndex == correct ? Color.LL.success : Color.LL.error
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Double")
                                .bold()
                                .foregroundColor(Color.LL.rebackground)

                            Text("Secure")
                                .bold()
                                .foregroundColor(Color.LL.orange)
                        }
                        .font(.largeTitle)

                        Text("Please select the word one by one refering to its order.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)

                    if case let .render(dataSource) = viewModel.state {
                        EnumeratedForEach(dataSource) { index, element in
                            VSegmentedPicker(model: model,
                                             state: selectArray[index] == element.correct ? .disabled : .enabled,
                                             selectedIndex: $selectArray[index],
                                             headerTitle: "Select the word #\(element.position)",
                                             data: element.list) { item in
                                VText(type: .oneLine,
                                      font: model.fonts.rows,
                                      color: getColor(selectIndex: selectArray[index],
                                                      item: item,
                                                      list: element.list,
                                                      currentListIndex: index,
                                                      correct: element.correct),
                                      title: item)
                            }
                            .padding(.bottom)
                        }
                    }
                }

                VPrimaryButton(model: ButtonStyle.primary,
                               state: isAllPass ? .enabled : .disabled,
                               action: {
                                   viewModel.trigger(.backupSuccess)
                               }, title: "Next")
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .onAppear {
                viewModel.trigger(.loadDataSource)
            }
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

struct ManualBackupView_Previews: PreviewProvider {
    static var previews: some View {
        ManualBackupView(viewModel: ManualBackupViewModel().toAnyViewModel())
            .colorScheme(.dark)
    }
}
