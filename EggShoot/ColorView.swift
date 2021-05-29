//
//  ColorView.swift
//  ColorView
//
//  Created by dohai on 10/25/14.
//  Copyright (c) 2014 dohai. All rights reserved.
//

import Foundation
import UIKit
class ColorView : UIView {
    init(frame : CGRect , hex : String ) {
        super.init(frame:frame)
             let label = UILabel(frame : CGRect(x: 0, y: 0, width: frame.width-10, height: 30))
            label.center = CGPoint(x: frame.width*0.5, y: frame.height*0.5)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            label.text = hex
            label.sizeToFit()
            self.addSubview(label)
            
      
        
     }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
 