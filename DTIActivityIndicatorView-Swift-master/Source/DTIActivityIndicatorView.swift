//
//  DTIActivityIndicatorView.swift
//
//  Created by dtissera on 12/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation

@IBDesignable
@objc
open class DTIActivityIndicatorView: UIView {
    // warning unlike objc, we dont have TARGET_INTERFACE_BUILDER macro in swift !
    // this variable as the right value only after prepareForInterfaceBuilder()
    // is called
    // https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-IB_objects_media/CreatingaLiveViewofaCustomObject.html
    // http://justabeech.com/2014/08/03/prepareforinterfacebuilder-and-property-observers/
    fileprivate var runningWithinInterfaceBuilder: Bool = false
    
    /** private properties */
    fileprivate var activityStarted: Bool = false
    
    fileprivate var currentAnimation: DTIAnimProtocol? = nil
    
    /** @IBInspectable properties */
    @IBInspectable open var indicatorColor: UIColor = UIColor.white {
        didSet {
            if (self.currentAnimation != nil) {
                self.currentAnimation!.needUpdateColor()
            }
        }
    }
    
    @IBInspectable open var indicatorStyle: String = DTIIndicatorStyle.convInv(.defaultValue)
    
    /** ctor && ~ctor */
    override public init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        if (self.activityStarted) {
            self.stopActivity(false)
        }
    }
    
    /** private members */
    fileprivate func setUpAnimation() {
        let style = DTIIndicatorStyle.conv(self.indicatorStyle)
        
        switch style {
        case .rotatingPane:self.currentAnimation = DTIAnimRotatingPlane(indicatorView: self)
        case .doubleBounce:self.currentAnimation = DTIAnimDoubleBounce(indicatorView: self)
        case .wave:self.currentAnimation = DTIAnimWave(indicatorView: self)
        case .wanderingCubes:self.currentAnimation = DTIAnimWanderingCubes(indicatorView: self)
        case .chasingDots:self.currentAnimation = DTIAnimChasingDots(indicatorView: self)
        case .pulse:self.currentAnimation = DTIAnimPulse(indicatorView: self)
        case .spotify:self.currentAnimation = DTIAnimSpotify(indicatorView: self)
        case .wp8:self.currentAnimation = DTIAnimWp8(indicatorView: self)
        }
        
        self.setUpColors()
    }
    
    fileprivate func setUpColors() {
        self.backgroundColor = UIColor.clear
        
        if (self.currentAnimation != nil) {
            self.currentAnimation!.needUpdateColor()
        }
    }
    
    /** overrides */
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.runningWithinInterfaceBuilder = true
        
        setUpColors();
    }
    
    override open func layoutSubviews() {
        if (self.currentAnimation != nil) {
            currentAnimation!.needLayoutSubviews()
        }
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if (self.runningWithinInterfaceBuilder) {
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            
            let arrayOfDashLength: [CGFloat] = [2.0, 2.0]
            context?.setStrokeColor(self.indicatorColor.cgColor)
            let dash = { (phase: CGFloat, lengths: [CGFloat], count: Int) -> Void in
                context?.setLineDash(phase: phase, lengths: lengths)
            }
            dash(0.0, arrayOfDashLength, arrayOfDashLength.count)
            
            context?.stroke(self.bounds)
            
            context?.restoreGState()
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        if (size.width < 20.0) {
            return CGSize(width: 20.0, height: 20.0)
        }
        // force width = height
        return CGSize(width: size.width, height: size.width)
    }
    
    /** public members */
    open func startActivity() {
        if (self.activityStarted) {
            return
        }
        
        self.activityStarted = true
        self.setUpAnimation()
        
        currentAnimation!.needLayoutSubviews()
        currentAnimation!.setUp()
        currentAnimation!.startActivity()
    }

    open func stopActivity(_ animated: Bool) {
        if (!self.activityStarted) {
            return
        }
        
        self.activityStarted = false;
        currentAnimation!.stopActivity(animated)
    }

    open func stopActivity() {
        self.stopActivity(true)
    }
    

}
