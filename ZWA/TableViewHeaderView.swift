//
//  TableViewHeaderView.swift
//  ZWA
//
//  Created by osx on 2017/8/3.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class TableViewHeaderView: UIView {

    var textLabel: UILabel!
    var switcher: BlockSwitch!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.groupTableViewBackground
        
        self.textLabel = UILabel(frame: CGRect(x: 15, y: 5, width: 33, height: 21))
        self.switcher = BlockSwitch(frame: CGRect(x: 303, y: 1, width: 51, height: 31))
        self.addSubview(self.textLabel)
        self.addSubview(self.switcher)
                
        
//        self.translatesAutoresizingMaskIntoConstraints = false
//        
//        let views: [String: AnyObject] = ["textLabel": self.textLabel, "switcher": self.switcher]
//        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[textLabel]-(>=20)-[switcher]-|", options: [.alignAllCenterY], metrics: nil, views: views)
////        constraints.append(NSLayoutConstraint(item: self.textLabel,
////                                         attribute: .centerY,
////                                         relatedBy: .equal,
////                                         toItem: self,
////                                         attribute: .centerY,
////                                         multiplier: 1,
////                                         constant: 0)
////        )
//        NSLayoutConstraint.activate(constraints)
    }
}
