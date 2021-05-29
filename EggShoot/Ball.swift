//
//  Ball.swift
//  EggShoot
//
//  Created by dohai on 1/18/15.
//  Copyright (c) 2015 dohai. All rights reserved.
//

import Foundation
import UIKit

struct Point {
    var row:Int
    var col:Int
}

infix operator === {}
//Equal operator
func ===(p1: Point, p2: Point) -> Bool {
    if (p1.row == p2.row) && (p1.col == p2.col) {
        return true
    } else {
        return false
    }
}


class Ball {
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    var vX:CGFloat = 0.0
    var vY:CGFloat = 0.0
    var r:CGFloat!
    var board : GameVC!
    var ballView : UIImageView!
    var ballType:Int! //0. Empty ball , 1.
    var ballLocation: Point!
    
    var isAlreadyCheckNeighbor:Bool = false
    var isCollide:Bool = false
    var isJump:Bool = false
    var isFall:Bool = false
    
    var jumpCount:Int = 0
    
    init (board:GameVC, ballType: Int, ballLocation:Point){
        self.board = board
        self.ballView = UIImageView(image: UIImage(named: "bubble_\(ballType).gif"))
        self.ballView.bounds = CGRect(x: 0, y: 0, width: board.ballWidth, height: board.ballWidth)
        self.ballView?.center = board.locationOfBall(ballLocation.col, row: ballLocation.row)
        self.board.view.addSubview(self.ballView)
        
        self.r = board.ballWidth/2
        self.ballType = ballType
        self.x = CGFloat(ballView.center.x)
        self.y = CGFloat(ballView.center.y)
        self.ballLocation = ballLocation
    }
    
    // Create empty ball
    init (){
        ballType = 0 // empty ball
    }
    
    // Set point when init shoot ball
    func setPosition(point: CGPoint){
        self.ballView?.center = board.locationOfBall(ballLocation.col, row: ballLocation.row)
        self.x = point.x
        self.y = point.y
     }
    
    func checkCollideWithBound(){
        var width = board.gameWidth
        var height = board.gameHeight
        
        if self.x - board.sideMargin  < r {
            self.x = r + board.sideMargin
            self.vX = -self.vX
        }
        
        if self.x  > width - r  - board.sideMargin{
            self.x = width - r - board.sideMargin
            self.vX = -self.vX
        }
        
        if self.y - board.topMargin < r {
             vY = -vY
             y = r + board.topMargin
        }
        
        if y > height - r {
            y = height - r
            vY = -vY
        }
    }
    
    func checkCollideWithOtherBall(otherBall: Ball) ->Bool{
        // Dont collide with jump ball
        if otherBall.isJump || otherBall.ballType == 0{
            return false
        }
        let doubleRadiusSquare = 4 * r * r
         if doubleRadiusSquare - pow(x - otherBall.x,2) - pow(y - otherBall.y, 2) > 0.01 {
            self.isCollide = true
            return true
        }else {
            return false
        }
    }
    
    func addFallBall(addCol: Int, addRow: Int){
        var k = board.cols*(self.ballLocation.row + addRow) + (self.ballLocation.col + addCol)
        if board.ballArray[k].ballType == 0 && board.ballArray[k].isAlreadyCheckNeighbor{
            return
        }
        
        // Should check if already contain to reject duplicate
        if self.ballType == board.ballArray[k].ballType {
            self.board.collideBallArray.append(board.ballArray[k])
            board.ballArray[k].checkNeigborBall()
        }
    }
    
    func checkNeigborBall(){
        if self.isAlreadyCheckNeighbor || self.ballType == 0{
            return
        }
        isAlreadyCheckNeighbor = true
         
        var currentRow = self.ballLocation.row
        var currentCol = self.ballLocation.col
        if currentRow % 2 == 0 {
             if currentCol > 0 {
                addFallBall(-1, addRow: 0)
            }
             if currentCol < 7 {
               addFallBall(1, addRow: 0)
                 if currentRow > 0 {
                    addFallBall(0, addRow: -1)
                    if currentCol > 0 {
                        addFallBall(-1, addRow: -1)
                    }
                }

                if currentRow < 11 {
                    addFallBall(0, addRow: 1)
                    if currentCol > 0 {
                        addFallBall(-1, addRow: 1)
                    }
                }
            }else {
                if currentRow > 0 {
                    addFallBall(0, addRow: -1)
                    if currentCol > 0 {
                        addFallBall(-1, addRow: -1)
                    }
                }
                if currentRow < 11 {
                    addFallBall(0, addRow: 1)
                    if currentCol > 0 {
                        addFallBall(-1, addRow: 1)
                    }
                }
            }
        }else {
            if currentCol < 7 {
                addFallBall(1, addRow: 0)
            }
            if currentCol > 0 {
                addFallBall(-1, addRow: 0)
                if currentRow > 0 {
                    addFallBall(0, addRow: -1)
                    if currentCol < 7 {
                        addFallBall(1, addRow: -1)
                    }
                }

                if currentRow < 11 {
                    addFallBall(0, addRow: 1)
                    if currentCol < 7 {
                        addFallBall(1, addRow: 1)
                    }
                 }
            }else {
                if currentRow > 0 {
                    addFallBall(0, addRow: -1)
                    if currentCol < 7 {
                        addFallBall(1, addRow: -1)
                    }
                }

                if currentRow < 11 {
                    addFallBall(0, addRow: 1)
                    if currentCol < 7 {
                        addFallBall(1, addRow: 1)
                    }
                }
            }
        }
    }
    
    // Get 9 ball around
    func getAroundBallTuples() ->[(Int,Int)]{
        var possiblePoints = [(Int,Int)]()
        if  self.ballType == 0{
            return possiblePoints
        }        
        
        var currentRow = self.ballLocation.row
        var currentCol = self.ballLocation.col
        if currentRow % 2 == 0 {
            if currentCol > 0 {
                possiblePoints.append((-1,0))
            }
            if currentCol < 7 {
                possiblePoints.append((1,0))
                if currentRow > 0 {
                    possiblePoints.append((0,-1))
                    if currentCol > 0 {
                        possiblePoints.append((-1,-1))
                    }
                }
                
                if currentRow < 11 {
                    possiblePoints.append((0,1))
                    if currentCol > 0 {
                        possiblePoints.append((-1,1))
                    }
                }
            }else {
                if currentRow > 0 {
                    possiblePoints.append((0,-1))
                    if currentCol > 0 {
                        possiblePoints.append((-1,-1))
                    }
                }
                if currentRow < 11 {
                    possiblePoints.append((0,1))
                    if currentCol > 0 {
                        possiblePoints.append((-1,1))
                    }
                }
            }
        }else {
            if currentCol < 7 {
                possiblePoints.append((1,0))
            }
            if currentCol > 0 {
                possiblePoints.append((-1,0))
                if currentRow > 0 {
                    possiblePoints.append((0,-1))
                    if currentCol < 7 {
                        possiblePoints.append((1,-1))
                    }
                }
                
                if currentRow < 11 {
                    possiblePoints.append((0,1))
                    if currentCol < 7 {
                        possiblePoints.append((1,1))
                    }
                }
            }else {
                if currentRow > 0 {
                    possiblePoints.append((0,-1))
                    if currentCol < 7 {
                        possiblePoints.append((1,-1))
                    }
                }
                
                if currentRow < 11 {
                    possiblePoints.append((0,1))
                    if currentCol < 7 {
                        possiblePoints.append((1,1))
                    }
                }
            }
        }
        return possiblePoints
    }
    
    func move(){
        x += vX
        y += vY
        self.ballView.center = CGPoint(x: x, y: y)
        if y > board.gameHeight - 100 {
            self.destroy()
        }
    }
    
    func stop(){
        self.vX = 0
        self.vY = 0
        self.ballView.removeFromSuperview()
    }
    
    // Funny jump balls
    func jumpAndFall(){
        isJump = true
        if !isFall {
            // Jump 20 times
            if jumpCount == 0 {
                self.vX = 2-CGFloat(arc4random_uniform(UInt32(4)))
                self.vY =  -6
            }else {
                self.vX -= vX/30
                self.vY -= vY/30
            }
            x += vX
            y += vY
            self.ballView.center = CGPoint(x: x, y: y)
            jumpCount++
            if jumpCount == 28 {
                isFall = true
            }
          }else {
            self.vY += 1/20;
            x += vX
            y += vY
            self.ballView.center = CGPoint(x: x, y: y)
        }
        
        if y > board.gameHeight - 100 {
            self.destroy()
        }
     }
    
    func destroy(){
        // Set to empty ball
        self.ballType = 0
        self.ballView.removeFromSuperview()
        for (index, ball) in enumerate(self.board.fallBallArray){
            if self.ballLocation === ball.ballLocation{
                self.board.fallBallArray.removeAtIndex(index)
                break
            }
        }
        
     }
    
    // Not check same color
    func addMoreFallBall(addCol: Int, addRow: Int){
        var k = board.cols*(self.ballLocation.row + addRow) + (self.ballLocation.col + addCol)
        if board.ballArray[k].ballType != 0 && !board.ballArray[k].isAlreadyCheckNeighbor{
            self.board.collideBallArray.append(board.ballArray[k])
            board.ballArray[k].checkMoreNeigborBall()
        }
    }
    
    func checkMoreNeigborBall(){
        if self.isAlreadyCheckNeighbor || self.ballType == 0{
            return
        }
        isAlreadyCheckNeighbor = true
        
        var currentRow = self.ballLocation.row
        var currentCol = self.ballLocation.col
        //        println("\(currentRow)__\(currentCol)")
        if currentRow % 2 == 0 {
            // Add left ball
            if currentCol > 0 {
                addMoreFallBall(-1, addRow: 0)
            }
            // Add right ball
            if currentCol < 7 {
                
                addMoreFallBall(1, addRow: 0)
                
                // Add top left and top right
                if currentRow > 0 {
                    addMoreFallBall(0, addRow: -1)
                    if currentCol > 0 {
                        addMoreFallBall(-1, addRow: -1)
                    }
                }
                
                // Add bot left and bot right
                // Add top left and top right
                if currentRow < 11 {
                    addMoreFallBall(0, addRow: 1)
                    if currentCol > 0 {
                        addMoreFallBall(-1, addRow: 1)
                    }
                }
                
            }else {
                if currentRow > 0 {
                    addMoreFallBall(0, addRow: -1)
                    if currentCol > 0 {
                        addMoreFallBall(-1, addRow: -1)
                    }
                }
                
                // Add bot left and bot right
                // Add top left and top right
                if currentRow < 11 {
                    addMoreFallBall(0, addRow: 1)
                    if currentCol > 0 {
                        addMoreFallBall(-1, addRow: 1)
                    }
                }
            }
        }else {
            if currentCol < 7 {
                addMoreFallBall(1, addRow: 0)
            }
            if currentCol > 0 {
                addMoreFallBall(-1, addRow: 0)
                
                // Add top left and top right
                if currentRow > 0 {
                    addMoreFallBall(0, addRow: -1)
                    if currentCol < 7 {
                        addMoreFallBall(1, addRow: -1)
                    }
                }
                
                // Add bot left and bot right
                // Add top left and top right
                if currentRow < 11 {
                    addMoreFallBall(0, addRow: 1)
                    if currentCol < 7 {
                        addMoreFallBall(1, addRow: 1)
                    }
                }
            }else {
                // Add top left and top right
                if currentRow > 0 {
                    addMoreFallBall(0, addRow: -1)
                    if currentCol < 7 {
                        addMoreFallBall(1, addRow: -1)
                    }
                }
                
                // Add bot left and bot right
                // Add top left and top right
                if currentRow < 11 {
                    addMoreFallBall(0, addRow: 1)
                    if currentCol < 7 {
                        addMoreFallBall(1, addRow: 1)
                    }
                }
            }
        }
    }

}