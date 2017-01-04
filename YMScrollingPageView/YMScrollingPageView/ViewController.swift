//
//  ViewController.swift
//  YMScrollingPageView
//
//  Created by KiBen on 17/1/4.
//  Copyright © 2017年 YioMidd. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet weak var pageView: ScrollingPageView!
    
    lazy var scrollPageView: ScrollingPageView = {
        var scrollV: ScrollingPageView = ScrollingPageView.init(frame: self.view.bounds)
        scrollV.backgroundColor = UIColor.lightGray
        return scrollV
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initializePageItemsWithIB()
        
        initialPageItems()
    }
    
    fileprivate func initialPageItems() {
        let cardSize:CGSize = CGSize.init(width: 250, height: 400)
        let cardCount: Int = 10
        
        self.scrollPageView.pageWidth = cardSize.width
        self.scrollPageView.pageHeight = cardSize.height
        for i in 0...cardCount {
            let itemView = UIView.init(frame: CGRect.init(x: CGFloat(i) * cardSize.width, y: 0, width: cardSize.width, height: cardSize.height))
            let card = UIView(frame: itemView.bounds.insetBy(dx: 10, dy: 10))
            card.backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / CGFloat(255), green: CGFloat(arc4random() % 256) / CGFloat(255), blue: CGFloat(arc4random() % 256) / CGFloat(255), alpha: 1)
            itemView.addSubview(card)
            scrollPageView.pageScrollView.addSubview(itemView)
        }
        self.view.addSubview(scrollPageView)
        scrollPageView.pageScrollView.contentSize = CGSize.init(width: CGFloat(cardCount + 1) * cardSize.width , height: 0)
    }
    
    fileprivate func initializePageItemsWithIB() {
        let cardCount: Int = 10
        for i in 0...cardCount {
            let itemView = UIView.init(frame: CGRect.init(x: CGFloat(i) * pageView.pageWidth, y: 0, width: pageView.pageWidth, height: pageView.pageHeight))
            let card = UIView(frame: itemView.bounds.insetBy(dx: 10, dy: 10))
            card.backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / CGFloat(255), green: CGFloat(arc4random() % 256) / CGFloat(255), blue: CGFloat(arc4random() % 256) / CGFloat(255), alpha: 1)
            itemView.addSubview(card)
            pageView.pageScrollView.addSubview(itemView)
        }
        pageView.pageScrollView.contentSize = CGSize.init(width: CGFloat(cardCount + 1) * pageView.pageWidth , height: 0)
    }
}

