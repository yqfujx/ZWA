//
//  MyActivityIndicatorView.swift
//  ZWA
//
//  Created by mac on 2017/3/24.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit
import DTIActivityIndicator

class MyActivityIndicatorView: UIView {
    weak var embedIndicator: DTIActivityIndicatorView!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(embedIndicator: DTIActivityIndicatorView) {
        let rect = UIScreen.main.bounds
        super.init(frame: rect)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        
        embedIndicator.center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        self.addSubview(embedIndicator)
        self.embedIndicator = embedIndicator
        embedIndicator.indicatorStyle = "spotify"
    }
    
    convenience init() {
        let embedIndicator = DTIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        self.init(embedIndicator: embedIndicator)
    }
    
    func show() -> Void {
        if let window = UIApplication.shared.keyWindow {
            self.embedIndicator.startActivity()
            window.addSubview(self)
        }
    }
    
    func dismiss() -> Void {
        self.embedIndicator.stopActivity()
        self.embedIndicator.removeFromSuperview()
        self.removeFromSuperview()
    }
}
