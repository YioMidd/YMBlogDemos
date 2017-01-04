//
//  ScrollingPageView.swift
//  YMScrollingPageView
//
//  Created by KiBen on 17/1/4.
//  Copyright © 2017年 YioMidd. All rights reserved.
//

import UIKit

private class PageScrollView: UIScrollView {
    override fileprivate func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}

class ScrollingPageView: UIView {
    
    var pageScrollView: UIScrollView!
    
    @IBInspectable public var pageWidth: CGFloat = 0 {
        didSet {
            if !pageWidth.isZero {
                var frame = pageScrollView.frame
                frame.size.width = pageWidth
                pageScrollView.frame = frame
            }
            pageScrollView.center = self.center
        }
    }
    
    @IBInspectable public var pageHeight: CGFloat = 0 {
        didSet {
            if !pageHeight.isZero {
                var frame = pageScrollView.frame
                frame.size.height = pageHeight
                pageScrollView.frame = frame
            }
            pageScrollView.center = self.center
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeChildView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeChildView()
    }

    private func initializeChildView() {
        let scrollView = PageScrollView.init(frame: self.bounds)
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        pageScrollView = scrollView
    }
}
