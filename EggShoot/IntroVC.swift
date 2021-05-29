//
//  IntroVC.swift
//  EggShoot
//
//  Created by dohai on 1/20/15.
//  Copyright (c) 2015 dohai. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {
    
    var gameManager = GameManager.sharedInstance


    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.whiteColor()
        var background = UIImageView(frame: self.view.bounds)
        background.image = UIImage(named: "splash2.png")
        self.view.addSubview(background)
        super.viewDidLoad()
        setLevel()

        var playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        playButton.setTitle("Play", forState: UIControlState.Normal)
        playButton.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(playButton)
        playButton.setTranslatesAutoresizingMaskIntoConstraints(false)

        let views = ["view": self.view, "playButton": playButton]
        self.view.addConstraint(NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80.0-[playButton]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
         // Do any additional setup after loading the view.
    }

    func onPlay(button: UIButton){
        println("click")
        let secondViewController:UIViewController = GameVC()
        self.presentViewController(secondViewController, animated: true, completion: nil)
    }
    
    func setLevel(){
        gameManager.setLevel(1)
    }
}
