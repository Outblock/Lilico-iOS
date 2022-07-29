//
//  AlertView.swift
//  Lilico
//
//  Created by Selina on 29/7/2022.
//

import SwiftUI

extension AlertView {
    enum ButtonType {
        case normal
        case confirm
        
        var titleColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.color
            case .confirm:
                return Color.LL.Button.text
            }
        }
        
        var bgColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.text
            case .confirm:
                return Color.LL.Neutrals.neutrals1
            }
        }
        
        var font: Font {
            return .inter(size: 14, weight: .semibold)
        }
    }
    
    struct ButtonItem {
        let id: String = UUID().uuidString
        let type: AlertView.ButtonType
        let title: String
        let action: () -> Void
    }
}

struct AlertView: View {
    @Binding var isPresented: Bool
    let title: String?
    let desc: String?
    let buttons: [AlertView.ButtonItem]
}

extension AlertView {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .visibility(isPresented ? .visible : .gone)
            
            contentView
                .padding(.bottom, 45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var contentView: some View {
        VStack(spacing: 27) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title ?? "")
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .visibility(title != nil ? .visible : .gone)
                
                Text(desc ?? "")
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .visibility(desc != nil ? .visible : .gone)
            }
            
            VStack(spacing: 8) {
                ForEach(buttons, id: \.id) { btn in
                    Button {
                        closeAction()
                        btn.action()
                    } label: {
                        createButtonLabel(item: btn)
                    }
                }
                
                defaultCancelButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 25)
        .padding(.bottom, 15)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.horizontal, 28)
        .zIndex(.infinity)
        .transition(.move(edge: .bottom))
        .visibility(isPresented ? .visible : .gone)
    }
    
    var defaultCancelButton: some View {
        let btn = AlertView.ButtonItem(type: .normal, title: "cancel".localized, action: {})
        return Button {
            closeAction()
        } label: {
            createButtonLabel(item: btn)
        }
    }
    
    @ViewBuilder func createButtonLabel(item: AlertView.ButtonItem) -> some View {
        Text(item.title)
            .font(item.type.font)
            .foregroundColor(item.type.titleColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                item.type.bgColor.cornerRadius(12)
            }
    }
}

extension AlertView {
    private func closeAction() {
        withAnimation(.easeInOut) {
            self.isPresented = false
        }
    }
}

struct AlertViewTestVM {
    @State var isPresented: Bool = true
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        let desc = "No account found with the recoveray phrase. Do you want to create a new account with your phrase?"
        let confirmBtn = AlertView.ButtonItem(type: .confirm, title: "Create Wallet") {
            
        }
        
        let vm = AlertViewTestVM()
        AlertView(isPresented: vm.$isPresented, title: "Account not Found", desc: desc, buttons: [confirmBtn])
    }
}
