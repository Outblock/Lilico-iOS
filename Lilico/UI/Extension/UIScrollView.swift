//
//  UIScrollView.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import MJRefresh

extension UIScrollView {
    
    // refreshing
    
    public func setRefreshingAction(_ action: @escaping () -> Void) {
        let header = MJRefreshNormalHeader(refreshingBlock: action)
        header.lastUpdatedTimeLabel?.isHidden = true
        header.stateLabel?.isHidden = true
        header.isAutomaticallyChangeAlpha = true
        self.mj_header = header
    }
    
    public func beginRefreshing() {
        self.mj_header?.beginRefreshing()
    }
    
    public func stopRefreshing() {
        self.mj_header?.endRefreshing()
    }
    
    public func isRefreshing() -> Bool {
        return self.mj_header?.isRefreshing ?? false
    }
    
    // loading
    
    public func setLoadingAction(_ action: @escaping () -> Void, noMoreDataLabelEnabled: Bool = true) {
        let footer = MJRefreshAutoStateFooter(refreshingBlock: action)
        footer.stateLabel?.textColor = UIColor(hex: "#888888")
        footer.stateLabel?.font = UIFont.systemFont(ofSize: 14)
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("松开开始加载", for: .pulling)
        footer.setTitle("正在加载", for: .refreshing)
        footer.setTitle(noMoreDataLabelEnabled ? "已显示全部内容" : "", for: .noMoreData)
        footer.triggerAutomaticallyRefreshPercent = 1
        footer.isAutomaticallyChangeAlpha = true
        self.mj_footer = footer
    }
    
    public func removeLoadingAction() {
        self.mj_footer = nil
    }
    
    public func beginLoading() {
        self.mj_footer?.beginRefreshing()
    }
    
    public func stopLoading() {
        self.mj_footer?.endRefreshing()
    }
    
    public func isLoading() -> Bool {
        return self.mj_footer?.isRefreshing ?? false
    }
    
    public func setNoMoreData(_ noMore: Bool) {
        if noMore {
            self.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        
        self.mj_footer?.resetNoMoreData()
    }
}

extension UIScrollView {
    public func scrollToTop(animated: Bool = true) {
        var off = self.contentOffset
        off.y = 0 - self.contentInset.top
        self.setContentOffset(off, animated: animated)
    }
}
