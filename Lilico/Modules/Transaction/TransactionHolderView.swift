//
//  TransactionHolderView.swift
//  Lilico
//
//  Created by Selina on 26/8/2022.
//

import UIKit
import SwiftUI
import SnapKit

private let PanelHolderViewWidth: CGFloat = 48
private let ProgressViewWidth: CGFloat = 32
private let IconImageViewWidth: CGFloat = 26

extension TransactionHolderView {
    enum Status {
        case dragging
        case left
        case right
    }
}

class TransactionHolderView: UIView {
    private(set) var model: TransactionManager.TransactionHolder?
    
    private var status: TransactionHolderView.Status = .right {
        didSet {
            reloadBgPaths()
        }
    }
    
    private lazy var bgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var progressBgLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(arcCenter: CGPoint(x: ProgressViewWidth/2.0, y: ProgressViewWidth/2.0), radius: ProgressViewWidth/2.0, startAngle: 0, endAngle: Double.pi * 2, clockwise: true).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(hex: "#F4F4F7").cgColor
        layer.lineWidth = 4
        layer.lineCap = .round
        return layer
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let startAngle = -Double.pi / 2.0
        layer.path = UIBezierPath(arcCenter: CGPoint(x: ProgressViewWidth/2.0, y: ProgressViewWidth/2.0), radius: ProgressViewWidth/2.0, startAngle: startAngle, endAngle: Double.pi * 2 + startAngle, clockwise: true).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(Color.LL.Primary.salmonPrimary).cgColor
        layer.lineWidth = 4
        layer.lineCap = .round
        layer.strokeEnd = 0.5
        return layer
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "flow")
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(IconImageViewWidth)
        }
        
        return imageView
    }()
    
    private lazy var progressContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.addSublayer(progressBgLayer)
        view.layer.addSublayer(progressLayer)
        
        view.addSubviews(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
     
        view.snp.makeConstraints { make in
            make.width.height.equalTo(ProgressViewWidth)
        }
        return view
    }()
    
    static func defaultPanelHolderFrame() -> CGRect {
        let size = Router.coordinator.window.bounds.size
        let x = size.width - PanelHolderViewWidth
        let y = size.height * 0.6
        return CGRect(x: x, y: y, width: PanelHolderViewWidth, height: PanelHolderViewWidth)
    }
    
    static func createView() -> TransactionHolderView {
        return TransactionHolderView(frame: LocalUserDefaults.shared.panelHolderFrame ?? defaultPanelHolderFrame())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        backgroundColor = .white
        
        layer.mask = bgMaskLayer
        
        addSubviews(progressContainerView)
        progressContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onPanelHolderPan(gesture:)))
        addGestureRecognizer(gesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
        
        addNotification()
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderStatusChanged(noti:)), name: .transactionStatusDidChanged, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadBgPaths()
    }
    
    private func reloadBgPaths() {
        bgMaskLayer.frame = bounds
        
        var corner: UIRectCorner
        switch status {
        case .dragging:
            corner = [.allCorners]
        case .right:
            corner = [.topLeft, .bottomLeft]
        case .left:
            corner = [.topRight, .bottomRight]
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: 12.0, height: 12.0))
        bgMaskLayer.path = path.cgPath
    }
    
    @objc private func onTap() {
        dismiss()
    }
    
    @objc private func onPanelHolderPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            status = .dragging
        case .ended, .cancelled, .failed:
            detectPosition()
        case .changed:
            let location = gesture.location(in: self.superview)
            self.center = location
        default:
            break
        }
    }
    
    private func detectPosition() {
        let window = Router.coordinator.window
        let height = window.bounds.size.height
        let width = window.bounds.size.width
        let midX = frame.midX
        
        status = midX > width / 2.0 ? .right : .left
        
        var finalFrame = frame
        finalFrame.origin.x = status == .right ? width - PanelHolderViewWidth : 0
        
        if finalFrame.origin.y < window.safeAreaInsets.top + 44 {
            finalFrame.origin.y = window.safeAreaInsets.top + 44
        } else if finalFrame.maxY > height - window.safeAreaInsets.bottom - 44 {
            finalFrame.origin.y = height - window.safeAreaInsets.bottom - PanelHolderViewWidth - 44
        }
        
        UIView.animate(withDuration: 0.25) {
            self.frame = finalFrame
        } completion: { completion in
            
        }
        
        saveCurrentFrame(finalFrame)
    }
    
    private func saveCurrentFrame(_ frame: CGRect) {
        LocalUserDefaults.shared.panelHolderFrame = frame
    }
    
    @objc private func onHolderStatusChanged(noti: Notification) {
        guard let holder = noti.object as? TransactionManager.TransactionHolder, model.id.hex == holder.id.hex else {
            return
        }
        
        refreshView()
    }
    
    private func refreshView() {
        
    }
}

extension TransactionHolderView {
    func show(inView: UIView) {
        
        self.alpha = 1
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut) {
            self.transform = .identity
        } completion: { _ in
            
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    func config(model: TransactionManager.TransactionHolder) {
        if let current = self.model, current.id.hex == model.id.hex {
            return
        }
        
        self.model = model
        refreshView()
    }
}
