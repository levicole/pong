//
//  ViewController.swift
//  pong
//
//  Created by Levi Kennedy on 8/11/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    var animator = UIDynamicAnimator()
    
    var ball     = UIView()
    var ballDynamicBehavior = UIDynamicItemBehavior()
    
    var player1  = UIView()
    var paddleDynamicBehavior = UIDynamicItemBehavior()

    var computer = UIView()
    var computerDynamicBehavior = UIDynamicItemBehavior()
    var computerPusher: UIPushBehavior?
    
    var divider  = UIView()
    var panGusture = UIPanGestureRecognizer()
    var pushBehavior = UIPushBehavior()
    var originalPaddleX = CGFloat()
    
    dynamic var player1Score       = Int(0)
    var player1ScoreLabel  = UILabel()
    dynamic var computerScore      = Int(0)
    var computerScoreLabel = UILabel()

    var catapultMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGrayColor()

        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        self.panGusture = UIPanGestureRecognizer(target: self, action: "movePlayer:")
        
        setupDivider()
        setupScoreBoards()
        setupPlayer1()
        setupComputer()
        createBall()
        launchTheBall()
        self.addObserver(self, forKeyPath: "player1Score", options: NSKeyValueObservingOptions.New, context: nil)
        self.addObserver(self, forKeyPath: "computerScore", options: NSKeyValueObservingOptions.New, context: nil)
        // set up key value observer for the users score
        // when player is behind by 5, enable catepult mode
        // on collision of the ball with the player, hold the all there
        // flash the text "SHAKE!!"
        // launch the ball at a high speed towards the computer such that it ensures a score
        // after the score set catepult mode to false
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
    
    func createBall() {
        let center = self.view.center;
        ball.removeFromSuperview()
        ball     = UIView(frame: CGRectMake(center.x, center.y, 10, 10))
        ball.backgroundColor = UIColor.redColor()
        view.addSubview(self.ball)
        ballDynamicBehavior = UIDynamicItemBehavior(items: [self.ball])
        ballDynamicBehavior.allowsRotation = false
        ballDynamicBehavior.friction   = 0.0
        ballDynamicBehavior.density    = 1.0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.resistance = 0.0
        animator.addBehavior(self.ballDynamicBehavior)
        createCollisions()
    }
    
    func launchTheBall() {
        self.pushBehavior = UIPushBehavior(items: [self.ball], mode: UIPushBehaviorMode.Instantaneous)
        
        var angle: CGFloat
        var magnitude: CGFloat
        
        if (catapultMode) {
            var ballX = self.ball.center.x
            var ballY = self.ball.center.y
            
            // top right corner
            var topX  = CGFloat(5)
            var topY  = CGFloat(0)
            
            var dx    = ballX - topX
            var dy    = ballY - topY
            
            angle = atan2(-dy, dx)
            magnitude = CGFloat(0.1)
        } else {
            angle = CGFloat(Float(arc4random())/Float(UInt32.max) * (2.35 - 0.78) + 0.78)
            magnitude = CGFloat(0.03)
        }
        
        
        
        pushBehavior.setAngle(angle, magnitude: magnitude)
        pushBehavior.action = {
            var location = self.ball.center
            var dx = location.x - self.computer.center.x
            
            var newLocation = CGPointMake(location.x - dx, self.computer.center.y)
            var newRect = CGRectMake(newLocation.x - (self.computer.frame.size.width / 2), self.computer.frame.origin.y, self.computer.frame.size.width, self.computer.frame.size.height)
            
            if (self.ball.frame.origin.y < 0) {
                self.createBall()
//                if (!self.catapultMode) { self.launchTheBall() }
                self.launchTheBall()
                self.player1Score += 1
            } else if (self.ball.frame.origin.y > CGRectGetMaxY(self.view.frame)){
                self.computerScore += 1
                self.createBall()
//                if (!self.catapultMode) { self.launchTheBall() }
                self.launchTheBall()
            }
            
            if self.computerPusher != nil {
                self.animator.removeBehavior(self.computerPusher)
            }
            
            if (CGRectContainsRect(self.view.frame, newRect)) {
                self.computerPusher = UIPushBehavior(items: [self.computer], mode: UIPushBehaviorMode.Instantaneous)
                if (self.computer.center.x < self.ball.center.x) {
                    self.computerPusher?.setAngle(0, magnitude: 7)
                    self.animator.addBehavior(self.computerPusher)
                } else if (self.computer.center.x > self.ball.center.x) {
                    self.computerPusher?.setAngle(CGFloat(M_PI), magnitude: 7.0)
                    self.animator.addBehavior(self.computerPusher)
                }
            }
            self.animator.updateItemUsingCurrentState(self.computer)
            
        }
        animator.addBehavior(pushBehavior)
    }
    
    func createCollisions() {
        var collisionBehavior = UICollisionBehavior(items: [ball, player1, computer])
        collisionBehavior.addBoundaryWithIdentifier("leftWall", fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(0, self.view.frame.size.height))
        collisionBehavior.addBoundaryWithIdentifier("rightWall", fromPoint: CGPointMake(self.view.frame.size.width, 0), toPoint: CGPointMake(self.view.frame.size.width, self.view.frame.size.height))
        collisionBehavior.collisionDelegate = self
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
        self.paddleDynamicBehavior.friction = 1.0
        self.paddleDynamicBehavior.resistance = 0.0
        animator.addBehavior(self.paddleDynamicBehavior)
    }
    
    func setupComputer() {
        var computerRect = CGRectMake(self.view.center.x, 20, 100, 15)
        computer = UIView(frame: computerRect)
        computer.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(computer)
        computerDynamicBehavior = UIDynamicItemBehavior(items: [computer])
        computerDynamicBehavior.allowsRotation = false
        computerDynamicBehavior.density = 1000
        computerDynamicBehavior.friction = 1.0
        computerDynamicBehavior.resistance = 0.8
        animator.addBehavior(computerDynamicBehavior)
    }
    
    func setupDivider() {
        self.divider = UIView(frame: CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 1))
        self.divider.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(self.divider)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "player1Score") {
            self.player1ScoreLabel.text = "\(player1Score)"
        } else if (keyPath == "computerScore") {
            self.computerScoreLabel.text = "\(computerScore)"
        }
        if (keyPath == "player1Score" || keyPath == "computerScore") {
            var scoreDiff = self.computerScore - self.player1Score
            if (scoreDiff > 5) {
                self.catapultMode = true
            } else {
                self.catapultMode = false
            }
        }
    }
    
    // I'm going to use this to change the angle of the ball based on where it hits the paddle
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        var view1 = item1 as! UIView
        var view2 = item2 as! UIView
        
        //  if ((view1 == player1 || view2 == player1) && catapultMode == true) {
        //      self.createBall()
        //      self.ball.center = CGPointMake(p.x, self.player1.frame.origin.y);
        //      self.animator.updateItemUsingCurrentState(self.ball)
        //  }
        if (view1 == self.ball || view2 == self.ball) {
            NSLog("\(self.pushBehavior.angle)")
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "player1Score")
        removeObserver(self, forKeyPath: "computerScore")
    }
}

