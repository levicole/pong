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
    var panGusture = UIPanGestureRecognizer()
    var ballDynamicBehavior = UIDynamicItemBehavior()
    var paddleDynamicBehavior = UIDynamicItemBehavior()
    var originalX = CGFloat()

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
        
        
        var player1Rect = CGRectMake(0, self.view.frame.height - 20, 100, 15)
        self.player1 = UIView(frame: player1Rect)
        self.player1.backgroundColor = UIColor.darkGrayColor()
        self.player1.addGestureRecognizer(self.panGusture)
        
        self.view.addSubview(self.player1)
        
        self.ballDynamicBehavior = UIDynamicItemBehavior(items: [self.ball])
        self.ballDynamicBehavior.allowsRotation = false
        self.ballDynamicBehavior.friction   = 0.0
        self.ballDynamicBehavior.elasticity = 1.0
        self.ballDynamicBehavior.resistance = 0.0
        animator.addBehavior(self.ballDynamicBehavior)
        
        self.paddleDynamicBehavior = UIDynamicItemBehavior(items: [self.player1])
        self.paddleDynamicBehavior.allowsRotation = false
        self.paddleDynamicBehavior.density = 1000
        animator.addBehavior(self.paddleDynamicBehavior)
        
        var pushBehavior = UIPushBehavior(items: [self.ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.setAngle(0.33, magnitude: 0.04)
        
        animator.addBehavior(pushBehavior)
        
        var collisionBehavior = UICollisionBehavior(items: [self.ball, self.player1])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehavior)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func movePlayer(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Began) {
            self.originalX = self.player1.center.x
        }
        var translation  = sender.translationInView(self.view)
        let newX = self.originalX + translation.x
        self.player1.center = CGPointMake(newX, self.player1.center.y)
        animator.updateItemUsingCurrentState(self.player1)
    }

}

