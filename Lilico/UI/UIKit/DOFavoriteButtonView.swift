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
    var isSelected: Bool
    var imageColor: UIColor
    let size: CGFloat = 48
    let imageColorOff: UIColor = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(Color(hex: "#4B4B4B")) : UIColor(Color(hex: "#E6E6E6"))
//    UIColor(Color.LL.outline)
    
    func makeUIView(context: Self.Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0
            , width: size, height: size))

        let button = DOFavoriteButton(frame: CGRect(x: 0, y: 0, width: size, height: size),
                                      image: UIImage(named: "icon-star-fill"))

        button.imageColorOff = imageColorOff
        button.imageColorOn = imageColor
        button.circleColor = imageColor
        button.lineColor = UIColor(Color.LL
            .Primary.salmonPrimary)
        button.duration = 1.5
        button.clipsToBounds = true
        button.contentMode = UIView.ContentMode.scaleAspectFill
//        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped(sender:)), for: UIControl.Event.touchUpInside)
        
        containerView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
        
        if isSelected {
            button.select()
        } else {
            button.deselect()
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let button = uiView.subviews.first as? DOFavoriteButton else {
            return
        }
        
        button.imageColorOn = imageColor
        button.circleColor = imageColor
        
        if isSelected {
            button.select()
        } else {
            button.deselect()
        }
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
//                button.callback(false)
                button.isSelected = false
           } else {
               // select with animation
               sender.select()
//               button.callback(true)
               button.isSelected = true
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
        DOFavoriteButtonView(isSelected: false, imageColor: .yellow)
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
