//
//  TransactionListBaseHandler.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import JXSegmentedView

class TransactionListBaseHandler: NSObject {
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
}

extension TransactionListBaseHandler: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return containerView
    }
}
