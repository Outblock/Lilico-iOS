//
//  EditAvatarView.swift
//  Lilico
//
//  Created by Selina on 15/6/2022.
//

import SwiftUI
import Kingfisher

struct EditAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditAvatarView(items: [.init(type: .string, avatarString: "1")])
        }
    }
}

private let PreviewContainerSize: CGFloat = 54
private let PreviewImageSize: CGFloat = 40

struct EditAvatarView: View {
    @StateObject private var vm: EditAvatarViewModel
    @EnvironmentObject private var router: ProfileEditCoordinator.Router
    
    init(items: [AvatarItemModel]) {
        _vm = StateObject(wrappedValue: EditAvatarViewModel(items: items))
    }
    
    var body: some View {
        ZStack() {
            VStack(spacing: 16) {
//                previewContainer
                scrollView
//                titleView
            }
            
            ZStack() {
                Button {
                    vm.save()
                } label: {
                    Text("done".localized)
                        .foregroundColor(.white)
                        .font(.inter(size: 14, weight: .semibold))
                        .padding(.horizontal, 19)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#333333"))
                        .cornerRadius(100)
                }
                .visibility(vm.mode == .preview ? .invisible : .visible)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#1A1A1A"))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack {
            Button {
                vm.mode = .edit
            } label: {
                Text("edit".localized)
                    .foregroundColor(.white)
                    .font(.inter(size: 14, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#333333"))
                    .cornerRadius(100)
            }
            .visibility(vm.mode == .preview ? .visible : .invisible)
        })
        .preferredColorScheme(.dark)
        .addBackBtn {
            router.pop()
        }
    }
}

extension EditAvatarView {
    var previewContainer: some View {
        ZStack {
            KFImage(URL(string: vm.currentSelectModel()?.getCover() ?? ""))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
            
            Color.black.opacity(0.5).reverseMask {
                Circle().padding(18)
            }
            .visibility(vm.mode == .preview ? .invisible : .visible)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(.black)
    }
    
    var scrollView: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { reader in
                    LazyHStack(spacing: 0) {
                        ForEach(vm.items, id: \.id) { item in
                            AvatarCell(isSelected: item.id == vm.selectedItemId, model: item).snapID(item.id)
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            reader.scrollTo(item.id, anchor: .center)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, proxy.size.width / 2.0 - PreviewContainerSize / 2.0)
                }
            }
            .snappable(alignment: .center, mode: .afterScrolling(decelerationRate: .fast)) { snapID in
                debugPrint("EditAvatarView -> afterScrolling")
                if let selectedId = snapID as? String {
                    vm.selectedItemId = selectedId
                }
            }
//            .visibility(vm.mode == .preview ? .invisible : .visible)
        }
        .frame(height: PreviewContainerSize)
    }
    
    var titleView: some View {
        Text(vm.currentSelectModel()?.getName() ?? "")
            .lineLimit(3)
            .foregroundColor(.white)
            .font(.inter(size: 14))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .visibility(vm.mode == .preview ? .invisible : .visible)
    }
}

extension EditAvatarView {
    struct AvatarCell: View {
        let isSelected: Bool
        let model: AvatarItemModel
        
        var body: some View {
            ZStack {
                LinearGradient(colors: [Color(hex: "#000000", alpha: 0), Color(hex: "#777777", alpha: 1)],
                               startPoint: .top,
                               endPoint: .bottom)
                .cornerRadius(4)
                .visibility(isSelected ? .visible : .invisible)
                
                KFImage(URL(string: model.getCover()))
                .frame(width: PreviewImageSize, height: PreviewImageSize)
                .background(.black)
                .cornerRadius(4)
                .opacity(isSelected ? 1 : 0.5)
            }
            .frame(width: PreviewContainerSize, height: PreviewContainerSize)
        }
    }
}
