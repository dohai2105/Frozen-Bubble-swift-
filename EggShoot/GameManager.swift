//
//  GameManager.swift
//  MineSweeper
//
//  Created by cuong minh on 1/6/15.
//  Copyright (c) 2015 Techmaster. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

//Khởi tạo GameManager như là một singleton, 
//có nghĩa chỉ tạo ra một đối tượng duy nhất suốt vòng đời của games
private let _SingletonASharedInstance = GameManager()
//TODO: Let code time constrained playing later !

enum gameState {
    case NotStart
    case Start
    case Pause
}

enum gameResult {
    case Win
    case GameOver
}

enum gameMode {
    case TimeElapse
    case NonTimeElapse
}
class GameManager {
    class var sharedInstance : GameManager {
        return _SingletonASharedInstance
    }
    //Đây là đoạn hàm khởi tạo gamemanager. Gọi trước khi game bắt đầu chơi
    //ví dụ như lấy lại hiện trạng game đang chơi từ lần trước
    init () {
        println("Will run to this line")
    }
    var isRunning: Bool = false
    var currentLevel: Int!
    var currentUser: String!
    var levelArr: [Int?] = [Int?]()
    var cols: Int = 8
    var rows: Int = 12
    var randomShootBallType: [Int] = [Int]()
    
    var currentMaxScore:Int!
    
    //GameManager cần chưa current gameLevel và các settings
//    var gameLevel: GameLevel!
    
    //Khởi động game với level beginner
    func start(level: Int = 1) {
        isRunning = true
    }
    
    //Dừng chơi nhạc nền
    func pause() {
        
    }
    
    
    func stop() {
        isRunning = false
    }
    var audioStickPlayer:AVAudioPlayer!
    var backgroundPlayer:AVAudioPlayer!
    var destroyGroupPlayer:AVAudioPlayer!
    
    func stickAudio(){
        var soundFilePath = NSBundle.mainBundle().pathForResource("stick", ofType: "mp3")
        var fileData = NSData(contentsOfFile: soundFilePath!, options: NSDataReadingOptions.allZeros, error: nil)
        audioStickPlayer = AVAudioPlayer(data: fileData, error: NSErrorPointer())
        audioStickPlayer.numberOfLoops = 1 //cấu hình để chơi liên tục
        audioStickPlayer.volume = 6
        audioStickPlayer.play() //chơi nhạc
    }
    
    func backgroundAudio(){
        var soundFilePath = NSBundle.mainBundle().pathForResource("payphone", ofType: "mp3")
        var fileData = NSData(contentsOfFile: soundFilePath!, options: NSDataReadingOptions.allZeros, error: nil)
        backgroundPlayer = AVAudioPlayer(data: fileData, error: NSErrorPointer())
        backgroundPlayer.volume = 2
        backgroundPlayer.numberOfLoops = 1 //cấu hình để chơi liên tục
        backgroundPlayer.play() //chơi nhạc
    }
    
    func destroyGroupAudio(){
        var soundFilePath = NSBundle.mainBundle().pathForResource("destroy_group", ofType: "mp3")
        var fileData = NSData(contentsOfFile: soundFilePath!, options: NSDataReadingOptions.allZeros, error: nil)
        destroyGroupPlayer = AVAudioPlayer(data: fileData, error: NSErrorPointer())
        destroyGroupPlayer.numberOfLoops = 1 //cấu hình để chơi liên tục
        destroyGroupPlayer.volume = 6
        destroyGroupPlayer.play() //chơi nhạc
    }
    
    // parser levels.txt file
    func setLevel(level:Int){
        currentLevel = level
        levelArr.removeAll(keepCapacity: false)
        randomShootBallType.removeAll(keepCapacity: false
        )
        let path = NSBundle.mainBundle().pathForResource("levels", ofType: "txt")
        var text = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        var levelContentArr = text.componentsSeparatedByString("\n\n")
        // println(levelContentArr[0])
        
        for index in 0..<(cols * 13)-1 {
            levelArr.append(nil)
        }
        for row in 0..<9 {
            // Random here
            var levelLine = levelContentArr[level].componentsSeparatedByString("\n")
            for col in 0..<(cols - row%2) {
                let k = cols*row + col
                var level = levelLine[row].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString("   ")
                if level[col].toInt() != nil {
                    levelArr[k] = level[col].toInt()!
                    randomShootBallType.append(level[col].toInt()!)
                }
            }
        }
        currentMaxScore = randomShootBallType.count
    }
    
    func getLevelArr()->[Int?]{
        return levelArr
    }
    
    func getRandomShootBallType() -> [Int]{
        return randomShootBallType
    }

}