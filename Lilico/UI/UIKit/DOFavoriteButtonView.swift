//
//  DOFavoriteButtonView.swift
//  Lilico
//
//  Created by Hao Fu on 9/9/2022.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

struct DOFavoriteButtonView: UIViewRepresentable {
    @Binding var isSelected: Bool
    let size: CGFloat = 48
    let imageColorOff: UIColor = UIColor(Color.LL.outline)
    let imageColorOn: UIColor =  UIColor(Color.LL
        .Secondary.mangoNFT)
    let circleColor: UIColor = UIColor(Color.LL
        .Secondary.mangoNFT)
    let lineColor: UIColor = UIColor(Color.LL
        .Primary.salmonPrimary)
    var callback: (Bool) -> ()
    
    func makeUIView(context: Self.Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0
            , width: size, height: size))

        let button = DOFavoriteButton(frame: CGRect(x: 0, y: 0, width: size, height: size),
                                      image: UIImage(named: "icon-star-fill"))

        button.imageColorOff = imageColorOff
        button.imageColorOn = imageColorOn
        button.circleColor = circleColor
        button.lineColor = lineColor
        button.duration = 1.0
        button.clipsToBounds = true
        button.contentMode = UIView.ContentMode.scaleAspectFill
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped(sender:)), for: UIControl.Event.touchUpInside)
        
        containerView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var button: DOFavoriteButtonView
        
        init(_ button: DOFavoriteButtonView) {
            self.button = button
        }
        
        @objc func tapped(sender: DOFavoriteButton) {
            if sender.isSelected {
                       // deselect
               sender.deselect()
                button.callback(false)
                button.isSelected = false
           } else {
               // select with animation
               sender.select()
               button.callback(true)
               button.isSelected = true
               UIImpactFeedbackGenerator(style: .medium).impactOccurred()
           }
            
//            sender.image = UIImage(named: sender.isSelected ? "icon-star-fill" : "icon-star")
        }
    }
}


struct DOFavoriteButtonView_Previews: PreviewProvider {
    
    static var toggleColor = Action()
    
    static var previews: some View {
//        Anything(DOFavoriteButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
//                                  image: UIImage(named: "icon-star-fill"))) { view in
//            view.addTarget(toggleColor, action: #selector(Action.perform(sender:)), for: .touchUpInside)
//        }
        DOFavoriteButtonView(isSelected: .constant(false)) { isSelect in
            
        }
        .previewLayout(.fixed(width: 50, height: 50))
        
    }
}

class Action: NSObject {
    var action: (() -> Void)?
    @objc func perform(sender: DOFavoriteButton) {
//                action?()
        
        if sender.isSelected {
                   // deselect
                   sender.deselect()
               } else {
                   // select with animation
                   sender.select()
               }
    }
}


struct Anything<Wrapper: UIView>: UIViewRepresentable {
    typealias Updater = (Wrapper, Context) -> Void

    var makeView: () -> Wrapper
    var update: (Wrapper, Context) -> Void
    var action: (() -> Void)?

    init(_ makeView: @escaping @autoclosure () -> Wrapper,
          updater update: @escaping (Wrapper) -> Void) {
        self.makeView = makeView
        self.update = { view, _ in update(view) }
    }

    func makeUIView(context: Context) -> Wrapper {
        makeView()
    }

    func updateUIView(_ view: Wrapper, context: Context) {
        update(view, context)
    }
}
