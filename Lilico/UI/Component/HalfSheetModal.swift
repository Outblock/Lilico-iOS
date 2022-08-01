//
//  HalfSheetModal.swift
//  ScrollToHide (iOS)
//
//  Created by Balaji on 08/07/21.
//


import SwiftUI

private let SheetHeaderHeight: CGFloat = 50

struct SheetHeaderView: View {
    let title: String
    var closeAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                
                Button(action: {
                    if let closeAction = closeAction {
                        closeAction()
                    } else {
                        defaultCloseAction()
                    }
                }) {
                    Image(systemName: "xmark").foregroundColor(.LL.Neutrals.neutrals8)
                }
                .frame(width: SheetHeaderHeight, height: SheetHeaderHeight)
            }
            .frame(maxWidth: .infinity)
            
            Text(title)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 18, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: SheetHeaderHeight)
    }
    
    private func defaultCloseAction() {
        Router.dismiss()
    }
}

// Custom Half Sheet Modifier....
extension View{
    
    // Binding Show Variable...
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView, onEnd: (() -> ())? = nil) -> some View {
        
        // why we using overlay or background...
        // bcz it will automatically use the swiftui frame Size only....
        return self
            .background(
                HalfSheetHelper(sheetView: sheetView(),showSheet: showSheet)
            )
            .onChange(of: showSheet.wrappedValue) { newValue in
                if let onEnd = onEnd, !newValue {
                    onEnd()
                }
            }
    }
}

// UIKit Integration...
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable{
    
    var sheetView: SheetView
    @Binding var showSheet: Bool
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        if showSheet{
            
            if uiViewController.presentedViewController == nil{
                
                // presenting Modal View....
                
                let sheetController = CustomHostingController(rootView: sheetView)
                sheetController.presentationController?.delegate = context.coordinator
                uiViewController.present(sheetController, animated: true)
            }
        }
        else{
            // closing view when showSheet toggled again...
            if uiViewController.presentedViewController != nil{
                uiViewController.dismiss(animated: true)
            }
        }
    }
    
    // On Dismiss...
    class Coordinator: NSObject,UISheetPresentationControllerDelegate{
        
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
        }
    }
}

// Custom UIHostingController for halfSheet....
class CustomHostingController<Content: View>: UIHostingController<Content>{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        // setting presentation controller properties...
        if let presentationController = presentationController as? UISheetPresentationController{
            presentationController.detents = [
                .medium()
            ]
            
            // to show grab protion...
//            presentationController.prefersGrabberVisible = true
        }
    }
}
