import SwiftUI

private let TopBarHeight: CGFloat = 50

struct BottomSheet<Background: View, SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let bg: () -> Background
    let sheetContent: () -> SheetContent
    
    private func closeAction() {
        withAnimation(.easeInOut) {
            self.isPresented = false
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .visibility(isPresented ? .visible : .gone)
            
            VStack(spacing: 0) {
                Button {
                    closeAction()
                } label: {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack {
                    ZStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                closeAction()
                            }) {
                                Image(systemName: "xmark").foregroundColor(.LL.Neutrals.neutrals8)
                            }
                            .frame(width: TopBarHeight, height: TopBarHeight)
                        }
                        
                        Text(title ?? "")
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 18, weight: .bold))
                    }
                    .frame(height: TopBarHeight)
                    
                    sheetContent()
                }
                .background(bg())
                .cornerRadius([.topLeft, .topRight], 16)
            }
            .zIndex(.infinity)
            .edgesIgnoringSafeArea(.vertical)
            .transition(.move(edge: .bottom))
            .visibility(isPresented ? .visible : .gone)
        }
    }
}

extension View {
    func customBottomSheet<Bg: View, SheetContent: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        background: @escaping () -> Bg = { Color.LL.deepBg as! Bg },
        sheetContent: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(BottomSheet(isPresented: isPresented, title: title, bg: background, sheetContent: sheetContent))
    }
}
