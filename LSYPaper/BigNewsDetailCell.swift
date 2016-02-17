//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public let bottomViewDefaultHeight:CGFloat = 55
private let transform3Dm34D:CGFloat = 1900.0
private let newsViewWidth:CGFloat = (SCREEN_WIDTH - 50) / 2
private let shiningImageHeight:CGFloat = (SCREEN_WIDTH - 50) * 296 / 325
private let newsViewY:CGFloat = SCREEN_HEIGHT - 20 - bottomViewDefaultHeight - newsViewWidth * 2
private let endAngle:CGFloat = CGFloat(M_PI) / 2.0
private let startAngle:CGFloat = CGFloat(M_PI) / 3.0
private let animateDuration:Double = 0.25
private let minScale:CGFloat = 0.97
private let baseShadowRedius:CGFloat = 50.0

class BigNewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var shiningViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var newsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var coreViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var shiningView: UIView!
    @IBOutlet weak private var shiningImage: UIImageView!
    @IBOutlet weak private var baseLayerView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var topLayer:CALayer = CALayer()
    private var bottomLayer:CALayer = CALayer()
    private var locationInSelf:CGPoint = CGPointZero
    private var translationInSelf:CGPoint = CGPointZero
    private var transform3D:CATransform3D = CATransform3DIdentity
    private var transformConcat:CATransform3D {
        return CATransform3DConcat(CATransform3DRotate(transform3D, transform3DAngle, 1, 0, 0), CATransform3DMakeTranslation(translationInSelf.x, 0, 0))
    }
    private var transformEndedConcat:CATransform3D {
        return CATransform3DConcat(CATransform3DConcat(CATransform3DRotate(transform3D, CGFloat(M_PI), 1, 0, 0), CATransform3DMakeTranslation(0, (SCREEN_WIDTH - newsViewY) - 20, 0)), CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1))
    }
    private var transform3DAngle:CGFloat {
        let cosUpper = locationInSelf.y - newsViewY >= (newsViewWidth * 2) ? (newsViewWidth * 2) : locationInSelf.y - newsViewY
        return acos(cosUpper / (newsViewWidth * 2))
            + asin((locationInSelf.y - newsViewY) / transform3Dm34D)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        totalView.layer.masksToBounds = true
        totalView.layer.cornerRadius = cellGap * 2
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 1.0
        baseLayerView.layer.shadowColor = UIColor.blackColor().CGColor
        baseLayerView.layer.shadowOffset = CGSizeMake(0, baseShadowRedius)
        baseLayerView.layer.shadowOpacity = 0.8
        baseLayerView.layer.shadowRadius = baseShadowRedius
        baseLayerView.alpha = 0.0
//        upperLayerView.layer.shadowColor = UIColor.blackColor().CGColor
//        upperLayerView.layer.shadowOffset = CGSizeMake(0, 0)
//        upperLayerView.layer.shadowOpacity = 0.8
//        upperLayerView.layer.shadowRadius = baseShadowRedius
//        upperLayerView.alpha = 0.0
        let pan = UIPanGestureRecognizer(target: self, action: "handleCollectPanGesture:")
        pan.delegate = self
        newsView.addGestureRecognizer(pan)
        panNewsView = pan
        transform3D.m34 = -1 / transform3Dm34D
    }
    
    func handleCollectPanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            newsView.layer.anchorPoint = CGPointMake(0.5, 0)
            newsViewBottomConstraint.constant = newsViewWidth
            shiningView.layer.anchorPoint = CGPointMake(0.5, 0)
            shiningViewBottomConstraint.constant = newsViewWidth
            locationInSelf = recognizer.locationInView(self)
            translationInSelf = recognizer.translationInView(self)
            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = self.transformConcat
                self.shiningView.layer.transform = self.transformConcat
                self.shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (self.transform3DAngle - startAngle) / (endAngle - startAngle))
                self.totalView.transform = CGAffineTransformMakeScale(minScale, minScale)
                self.baseLayerView.alpha = 1.0
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            locationInSelf = recognizer.locationInView(self)
            translationInSelf = recognizer.translationInView(self)
            newsView.layer.transform = transformConcat
            shiningView.layer.transform = transformConcat
            baseLayerView.layer.transform = CATransform3DMakeTranslation(translationInSelf.x, 0, 0)
            shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (transform3DAngle - startAngle) / (endAngle - startAngle))
            shiningImage.alpha = transform3DAngle / CGFloat(M_PI) >= 0.5 ? 0 : 1
            shiningView.backgroundColor = transform3DAngle / CGFloat(M_PI) >= 0.5 ? UIColor.whiteColor() : UIColor.clearColor()
            print(transform3DAngle / CGFloat(M_PI))
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                if recognizer.velocityInView(self).y <= 0 {
                    self.newsView.layer.transform = self.transformEndedConcat
                    self.shiningView.layer.transform = self.transformEndedConcat
                    self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1), CATransform3DMakeTranslation(0, SCREEN_WIDTH - newsViewY, 0))
                    self.shiningImage.alpha = 0.0
                    self.shiningView.backgroundColor = UIColor.whiteColor()
                }else {
                    self.newsView.layer.transform = CATransform3DIdentity
                    self.shiningView.layer.transform = CATransform3DIdentity
                    self.shiningImage.transform = CGAffineTransformIdentity
                    self.totalView.transform = CGAffineTransformIdentity
                    self.baseLayerView.layer.transform = CATransform3DIdentity
                    self.shiningImage.alpha = 1.0
                    self.shiningView.backgroundColor = UIColor.clearColor()
                    self.baseLayerView.alpha = 0.0
                }
                },completion: { (stop:Bool) -> Void in
            })
        }
    }
}

extension BigNewsDetailCell:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panNewsView && (panNewsView.velocityInView(self).y >= 0) || fabs(panNewsView.velocityInView(self).x) >= fabs(panNewsView.velocityInView(self).y) {
            return false
        }else {
            return true
        }
    }
}
