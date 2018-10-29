//
//  PopAnimator.swift
//  PixelCity
//
//  Created by Sultan Karybaev on 10/29/18.
//  Copyright © 2018 Sultan Karybaev. All rights reserved.
//

import Foundation
import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    var originFrame = CGRect.zero
    var presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //1) Set up transition
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let popView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : popView.frame
        let finalFrame = presenting ? popView.frame : originFrame
        
        let xScaleFactor = presenting
            ? initialFrame.width / finalFrame.width
            : finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting
            ? initialFrame.height / finalFrame.height
            : finalFrame.height / initialFrame.height
        
        let scaleFactor = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            popView.transform = scaleFactor
            popView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            popView.alpha = 0
        }
        
//        popView.layer.cornerRadius = self.presenting ? 20.0 / xScaleFactor : 0.0
        popView.clipsToBounds = true
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: popView)
        
//        let herbController = transitionContext.viewController(
//            forKey: presenting ? .to : .from
//            ) as! PopVC
        
//        if presenting {
//            herbController.containerView.alpha = 0.0
//        }
        
        UIView.animate(withDuration: duration, animations: {
            popView.layer.cornerRadius = self.presenting ? 0.0 : 20.0 / xScaleFactor
            popView.transform = self.presenting ? .identity : scaleFactor
            popView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            popView.alpha = self.presenting ? 1 : 0
            //herbController.containerView.alpha = self.presenting ? 1.0 : 0.0
        }, completion: { _ in
            if !self.presenting {
                let viewController = transitionContext.viewController(forKey: .to) as! MapVC
                viewController.selectedImage?.isHidden = false
            }
            transitionContext.completeTransition(true)
        })
        
    }
}
