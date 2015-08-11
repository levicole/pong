//
//  ViewController.swift
//  pong
//
//  Created by Levi Kennedy on 8/11/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var animator = UIDynamicAnimator()
    var ball     = UIView()
    var player1  = UIView()
    var divider  = UIView()
    var panGusture = UIPanGestureRecognizer();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        self.divider = UIView(frame: CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 1))
        self.divider.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(self.divider)
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        self.ball     = UIView(frame: CGRectMake(100, 100, 10, 10))
        self.ball.backgroundColor = UIColor.redColor()
        self.view.addSubview(self.ball)
        
        self.panGusture = UIPanGestureRecognizer(target: self, action: "movePlayer:")
        self.view.addGestureRecognizer(self.panGusture)
        
        
        var player1Rect = CGRectMake(0, self.view.frame.height - 10, 80, 5)
        self.player1 = UIView(frame: player1Rect)
        self.player1.backgroundColor = UIColor.darkGrayColor()
        
        self.view.addSubview(self.player1)
        
        var dynamicBehavior = UIDynamicItemBehavior(items: [self.ball])
        var pushBehavior = UIPushBehavior(items: [self.ball], mode: UIPushBehaviorMode.Continuous)
        pushBehavior.setAngle(0.33, magnitude: 0.04)
        
        animator.addBehavior(pushBehavior)
        animator.addBehavior(dynamicBehavior)
        
        var collisionBehavior = UICollisionBehavior(items: [self.ball])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehavior)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func movePlayer(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(self.view)
        self.player1.frame = CGRectMake(location.x, self.view.frame.height - 10, 80, 5)
        animator.updateItemUsingCurrentState(self.player1)
    }

}

