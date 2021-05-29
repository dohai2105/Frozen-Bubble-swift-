//
//  ViewController.swift
//  EggShoot
//
//  Created by dohai on 1/18/15.
//  Copyright (c) 2015 dohai. All rights reserved.
//

import UIKit

class GameVC: UIViewController , UIAlertViewDelegate ,UIGestureRecognizerDelegate{
  
    var margin: CGFloat!
    var cols: Int = 8
    var rows: Int = 12
    var ballWidth: CGFloat!
    var gameWidth:CGFloat!
    var gameHeight:CGFloat!
    
    var shotBall: Ball!
    var gunView:UIImageView!
    
    var ballArray:[Ball]=[Ball]()
    var fallBallArray:[Ball] = [Ball]()
    var collideBallArray:[Ball] = [Ball]()
    
    var randomShootBallType: [Int]!
    
    var MAX_BALL_SPEED:CGFloat = 8
    var sideMargin:CGFloat = 25
    var topMargin:CGFloat = 40
    
    var gameManager = GameManager.sharedInstance
    var timer:NSTimer!
    
    var isWin = false
    
    var tapOnScreen: UITapGestureRecognizer?
    var tapOnDialog: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        var background = UIImageView(frame: self.view.bounds)
        background.image = UIImage(named: "bg.png")
        self.view.addSubview(background)
        initLevel()
        initBallArray()
        initBoard()
        initGun()
        
        initCONTROL()
    }
    
    func initLevel(){
        randomShootBallType = gameManager.getRandomShootBallType()
    }
    
    // Create empty ball array 8x13
    func initBallArray(){
        for row in 0..<rows{
            for col in 0..<cols  {
                ballArray.append(Ball())
            }
        }
    }

    func initCONTROL(){
        tapOnScreen = UITapGestureRecognizer(target: self, action: "onTap:")
        tapOnScreen!.delegate = self
        self.view.addGestureRecognizer(tapOnScreen!)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loop:", userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func onTap(tap: UITapGestureRecognizer){
        var pointTap = tap.locationInView(self.view)
        var distanX = (shotBall.ballView.center.x - pointTap.x)
        var distanY = (shotBall.ballView.center.y - pointTap.y)
        var atan = atan2(distanY,distanX)
        
        // Add ball velocity and rotate arrow
        if (atan > 0){
            shotBall.vX = CGFloat(cos(atan + CGFloat(M_PI)))*MAX_BALL_SPEED
            shotBall.vY = CGFloat(sin(atan + CGFloat(M_PI)))*MAX_BALL_SPEED
            // Decrease -pi/2
            gunView.transform = CGAffineTransformMakeRotation(atan - CGFloat(M_PI/2))
        }
    }
    
    func loop(timer: NSTimer) {
        if !shotBall.isCollide{
            shotBall.checkCollideWithBound()
            for (index,ball) in enumerate(ballArray){
                if shotBall.checkCollideWithOtherBall(ball) {
                    if shotBall.ballType == ball.ballType {
                        self.collideBallArray.append(shotBall)
                        ball.checkNeigborBall()
                        // If collide > 2 ball -> jump, else add more ball
                        if collideBallArray.count > 2 {
                            gameManager.destroyGroupAudio()
                            for ball in collideBallArray {
                                fallBallArray.append(ball)
                            }
                            getMoreFallingBall()
                        }else {
                            addMoreBall(ball)
                            shotBall.destroy()
                        }
                    }else {
                        addMoreBall(ball)
                        shotBall.destroy()
                    }
                    
                    // Reset array
                    collideBallArray.removeAll(keepCapacity: false)
                    for ball in ballArray {
                        if ball.ballType != 0 {
                            ball.isAlreadyCheckNeighbor = false
                        }
                    }
                    creatShotBall()
                    break
                 }
            }
        }
        shotBall.move()
        for ball in fallBallArray{
            if ball.ballType != 0{
                ball.jumpAndFall()
            }
        }
        // If ball falls out screen
        if shotBall.ballView.center.y > gameHeight - 100 {
            shotBall.destroy()
            creatShotBall()
        }
        // Check Win
        if getNumberOfBall() == 0 {
            isWin = true
            stopAnimation()
        }
    }
    
    func getMoreFallingBall(){
        collideBallArray.removeAll(keepCapacity: false)
        for row in 0..<rows {
            for col in 0..<(cols - row%2) {
                if col == 0 || row == 0 || col == 7 {
                    let k = cols*row + col
                    if ballArray [k].ballType != 0 {
                        ballArray[k].checkMoreNeigborBall()
                        collideBallArray.append(ballArray[k])
                    }
                }
            }
        }
        
        for ball1 in ballArray {
            if ball1.ballType != 0 {
                var duplicate = false
                for ball2 in collideBallArray {
                    if ball1.ballLocation === ball2.ballLocation {
                        duplicate = true
                        break
                    }
                }
                if !duplicate {
                    fallBallArray.append(ball1)
                }
            }
        }
       
     }
    
    // Check 9 possible positions around
    func addMoreBall(ball:Ball){
        gameManager.stickAudio()
        if ball.ballLocation.row == 11 {
            stopAnimation()
            return
        }
        var point = ball.ballLocation
        var possibleBallTuples = ball.getAroundBallTuples()
        var smallestDistance:CGFloat = 10000
        var nearestBallTupe:(Int,Int) = (0,0)
        for tuple in possibleBallTuples {
            var k = cols*(point.row + tuple.1) + (point.col + tuple.0)
            var emptyBallPoint = self.locationOfBall(point.col + tuple.0, row: point.row + tuple.1)
            var distance = pow(shotBall.ballView.center.x - emptyBallPoint.x,2) + pow(shotBall.ballView.center.y - emptyBallPoint.y,2)
            if smallestDistance > distance && self.ballArray[k].ballType == 0 {
                smallestDistance = distance
                nearestBallTupe = tuple
            }
        }
        
        // If ok
        if smallestDistance != 10000{
            var newball = Ball(board: self, ballType: shotBall.ballType, ballLocation: Point(row: point.row + nearestBallTupe.1, col: point.col + nearestBallTupe.0))
            var k = cols*(point.row + nearestBallTupe.1) + (point.col + nearestBallTupe.0)
            self.ballArray[k] = newball
            
         
            for ball in ballArray {
                if ball.ballType != 0 {
                    ball.isAlreadyCheckNeighbor = false
                }
            }
            collideBallArray.removeAll(keepCapacity: false)
            //self.collideBallArray.append(newball)
            newball.checkNeigborBall()
            if collideBallArray.count > 2 {
                for ball in collideBallArray {
                    fallBallArray.append(ball)
                }
                getMoreFallingBall()
            }
        }
    }
    
  
    
    func initBoard(){
        let viewSize = view.bounds.size
        gameWidth = viewSize.width
        gameHeight = viewSize.height
        self.margin = 25
        ballWidth = (viewSize.width-margin*2)/CGFloat(cols)
        
        // Ve view tren ma tran cells
        for row in 0..<rows {
            for col in 0..<(cols - row%2) {
                let k = cols*row + col
                var center = self.locationOfBall(col, row: row)
                if gameManager.getLevelArr()[k] != nil {
                     var ball = Ball(board: self, ballType: gameManager.getLevelArr()[k]! , ballLocation:Point(row: row, col: col))
                     self.ballArray[k] = ball
                }
            }
        }
    }
    
    func locationOfBall(col:Int , row:Int)->CGPoint{
        self.margin = 25
        if row%2 != 0 {
            self.margin = 25+ballWidth/2
        }
        return CGPoint(x: self.margin + ballWidth*(CGFloat(col)+0.5) , y: 40 + (CGFloat(row)+0.5)*ballWidth)
    }
    
    func initGun(){
        gunView = UIImageView(image: UIImage(named: "launcher"))
        gunView.center = CGPoint(x: gameWidth/2, y: gameHeight-100)
        self.view.addSubview(gunView)
        creatShotBall()
    }
    
    // To seperate ball when destroy
    var ballNumber = 1000
    func creatShotBall(){
        var randomType = arc4random_uniform(UInt32(randomShootBallType.count))
        if randomShootBallType[Int(randomType)] == 0 {
            randomType = arc4random_uniform(UInt32(randomShootBallType.count))
        }
        shotBall = Ball(board: self,ballType:randomShootBallType[Int(randomType)],ballLocation:Point(row: ballNumber, col: ballNumber))
        shotBall.setPosition(gunView.center)
        ballNumber++
    }
    
    func startAnimation(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loop:", userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func stopAnimation(){
        shotBall.destroy()
        timer.invalidate()
        if !isWin{
            var alert = UIAlertView(title: "Kết quả", message: "Bạn thua rồi", delegate: self, cancelButtonTitle: "Quay lại")
            alert.show()
            for ball in ballArray {
                if ball.ballType != 0{
                    ball.ballView.image = UIImage(named: "frozen_\(ball.ballType).gif")
                }
            }
        }else {
            self.view.removeGestureRecognizer(tapOnScreen!)
            var winImage = UIImageView(image: UIImage(named: "win_panel.jpg"))
            winImage.center = CGPoint(x: gameWidth/2, y: gameHeight/2)
            tapOnDialog = UITapGestureRecognizer(target: self, action: "onTapWinView:")
            winImage.userInteractionEnabled = true
            winImage.multipleTouchEnabled = true
            tapOnDialog!.delegate = self
            winImage.addGestureRecognizer(tapOnDialog!)
            
            self.view.addSubview(winImage)
            self.view.bringSubviewToFront(winImage)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let firstViewController:UIViewController = IntroVC()
        self.presentViewController(firstViewController, animated: true, completion: nil)
    }
    
    func onTapWinView (tap: UITapGestureRecognizer) {
        gameManager.setLevel(gameManager.currentLevel+1)
        let secondViewController:UIViewController = GameVC()
        self.presentViewController(secondViewController, animated: true, completion: nil)
    }
    
    
    func getNumberOfBall()->Int{
        var count = 0
        for ball in ballArray {
            if ball.ballType != 0 {
                count++
            }
        }
        return count
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer === tapOnScreen) && (otherGestureRecognizer === tapOnDialog) {
            return true
        } else {
            return false
        }
    }
}

