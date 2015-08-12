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
    var pushBehavior = UIPushBehavior()
    var originalPaddleX = CGFloat()
    
    var player1Score       = Int(0) {
        didSet {
            self.player1ScoreLabel.text = "\(player1Score)"
        }
    }
    var player1ScoreLabel  = UILabel()
    var computerScore      = Int() {
        didSet {
            self.computerScoreLabel.text = "\(computerScore)"
        }
    }
    var computerScoreLabel = UILabel()
    private var myContext = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGrayColor()

        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        self.panGusture = UIPanGestureRecognizer(target: self, action: "movePlayer:")
        
        setupDivider()
        setupScoreBoards()
        setupPlayer1()
        createBall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func movePlayer(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Began) {
            self.originalPaddleX = self.player1.center.x
        }
        var translation  = sender.translationInView(self.view)
        var newX = self.originalPaddleX + translation.x
        let halfWidth = self.player1.frame.width/2
        if ((newX + halfWidth) > self.view.frame.width) {
            newX = self.view.frame.size.width - halfWidth
        } else if (newX - halfWidth < 0) {
            newX = newX + halfWidth
        }
        self.player1.center = CGPointMake(newX, self.player1.center.y)
        animator.updateItemUsingCurrentState(self.player1)
    }
    
    func resetBallFrame() {
        self.ball.frame.origin = CGPointMake(self.view.frame.width/2, self.view.frame.size.height/2)
        pushBehavior.active = true
    }
    
    func createBall() {
        let center = self.view.center;
        ball     = UIView(frame: CGRectMake(center.x, center.y, 10, 10))
        ball.backgroundColor = UIColor.redColor()
        view.addSubview(self.ball)
        ballDynamicBehavior = UIDynamicItemBehavior(items: [self.ball])
        ballDynamicBehavior.allowsRotation = false
        ballDynamicBehavior.friction   = 0.0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.resistance = 0.0
        animator.addBehavior(self.ballDynamicBehavior)
        createCollisions()
        launchTheBall()
    }
    
    func launchTheBall() {
        self.pushBehavior = UIPushBehavior(items: [self.ball], mode: UIPushBehaviorMode.Instantaneous)
        
        let angle = CGFloat(Float(arc4random())/Float(UInt32.max))
        
        pushBehavior.setAngle(angle, magnitude: 0.04)
        pushBehavior.action = {
            if (self.ball.frame.origin.y < 0) {
                self.createBall()
                self.player1Score += 1
            } else if (self.ball.frame.origin.y > CGRectGetMaxY(self.view.frame)){
                self.computerScore += 1
                self.createBall()
            }
        }
        animator.addBehavior(pushBehavior)
    }
    
    func createCollisions() {
        var collisionBehavior = UICollisionBehavior(items: [self.ball, self.player1])
        collisionBehavior.addBoundaryWithIdentifier("leftWall", fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(0, self.view.frame.size.height))
        collisionBehavior.addBoundaryWithIdentifier("rightWall", fromPoint: CGPointMake(self.view.frame.size.width, 0), toPoint: CGPointMake(self.view.frame.size.width, self.view.frame.size.height))
        animator.addBehavior(collisionBehavior)
    }
    
    func setupScoreBoards() {
        player1Score  = 0
        player1ScoreLabel = UILabel(frame: CGRectMake(10, self.view.frame.size.height/2 + 20, 20, 20))
        player1ScoreLabel.backgroundColor = UIColor.blackColor()
        player1ScoreLabel.alpha = 0.5
        player1ScoreLabel.text = "\(player1Score)"
        player1ScoreLabel.textColor = UIColor.whiteColor()
        player1ScoreLabel.textAlignment = NSTextAlignment.Center
        player1ScoreLabel.layer.cornerRadius = 3
        player1ScoreLabel.layer.masksToBounds = true
        computerScoreLabel = UILabel(frame: CGRectMake(10, self.view.frame.size.height/2 - 40, 20, 20))
        computerScoreLabel.backgroundColor = UIColor.blackColor()
        computerScoreLabel.alpha = 0.5
        computerScoreLabel.textColor = UIColor.whiteColor()
        computerScoreLabel.textAlignment = NSTextAlignment.Center
        computerScoreLabel.layer.cornerRadius = 3
        computerScoreLabel.layer.masksToBounds = true
        computerScore = 0
        
        self.view.addSubview(player1ScoreLabel)
        self.view.addSubview(computerScoreLabel)
        
    }
    
    func setupPlayer1() {
        var player1Rect = CGRectMake(0, self.view.frame.height - 20, 100, 15)
        self.player1 = UIView(frame: player1Rect)
        self.player1.backgroundColor = UIColor.darkGrayColor()
        self.player1.addGestureRecognizer(self.panGusture)
        self.view.addSubview(self.player1)
        self.paddleDynamicBehavior = UIDynamicItemBehavior(items: [self.player1])
        self.paddleDynamicBehavior.allowsRotation = false
        self.paddleDynamicBehavior.density = 1000
        self.paddleDynamicBehavior.friction = 0.1
        animator.addBehavior(self.paddleDynamicBehavior)
    }
    
    func setupDivider() {
        self.divider = UIView(frame: CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 1))
        self.divider.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(self.divider)
    }
}

