//
//  ViewController.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "NewsDetailCell"
private let maxTitleLabelY = SCREEN_WIDTH + 15
private let collectionViewFrame = CGRectMake(0, POSTER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - POSTER_HEIGHT)


class ViewController: UIViewController {
    private let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageControl()
        setMessageView()
        setCollectionView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

private extension ViewController {
    private func setPageControl() {
        
        let path = NSBundle.mainBundle().pathForResource("Section", ofType: "plist")
        let dicArray = NSArray(contentsOfFile: path!)
        
        var views = [UIView]()
        for index in 0 ..< dicArray!.count {
            let dic = dicArray?.objectAtIndex(index)
            let data = SectionData(dictionary: dic as! [String : AnyObject])
            let frame = CGRectMake(SCREEN_WIDTH * CGFloat(index), 0, SCREEN_WIDTH, SCREEN_HEIGHT)
            let view = SectionPosterView.sectionPosterViewWith(data: data, frame: frame)
            if index == 0 {
                setTopRoundCorner(forView: view, cornerOption: UIRectCorner.TopLeft)
            }
            
            if index == 9 {
                setTopRoundCorner(forView: view, cornerOption: UIRectCorner.TopRight)
            }
            views.append(view)
        }
        
        let pageControl = LSYPageControl.pageControlWith(CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), views: views)
        pageControl.pageControlBottomConstraint.constant = SCREEN_HEIGHT - POSTER_HEIGHT
        pageControl.didScrollOption = {(targetPage:NSInteger,views:[UIView]) in
            let view = views[targetPage] as! SectionPosterView
            let frame = view.titleLabel.convertRect(view.titleLabel.bounds, toView: self.view)
            
            let rightEdge = SCREEN_WIDTH - 20
            let leftEdge = SCREEN_WIDTH - 151
            if frame.origin.x > rightEdge {
                view.titleLabel.alpha = (frame.origin.x - rightEdge) / view.titleLabel.bounds.width
            }else if frame.origin.x <= rightEdge && frame.origin.x >= leftEdge {
                view.titleLabel.alpha = 0.0;
            }else {
                view.titleLabel.alpha = (leftEdge - frame.origin.x) / view.titleLabel.bounds.width
            }
        }
        view.addSubview(pageControl)
        
        setTopRoundCorner(forView: view, cornerOption: [UIRectCorner.TopLeft,UIRectCorner.TopRight])
    }
    private func setTopRoundCorner(forView view:UIView,cornerOption:UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: cornerOption, cornerRadii: CGSizeMake(6, 6))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds;
        maskLayer.path = maskPath.CGPath;
        view.layer.mask = maskLayer;
    }
    private func setMessageView() {
        let messageView = MessageView.messageViewWith(frame: CGRectMake(SCREEN_WIDTH - 135, 0, 135, 55))
        view.addSubview(messageView)
    }
    private func setCollectionView() {
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        let nib = UINib(nibName: cellReuseIdentifier, bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        view.addSubview(collectionView)
    }
}

extension ViewController:UICollectionViewDelegate {
    
}

extension ViewController:UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        return cell
    }
}

