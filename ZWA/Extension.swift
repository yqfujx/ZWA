//
//  Extension.swift
//  ConchIOS
//
//  Created by osx on 2017/7/14.
//  Copyright © 2017年 osx. All rights reserved.
//

import Foundation

extension Date {
    var year: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.year, from: self)
        }
    }
    
    var month: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.month, from: self)
        }
    }
    
    var day: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.day, from: self)
        }
    }
    
    var hour: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.hour, from: self)
        }
    }
    
    var minute: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.minute, from: self)
        }
    }
    
    var second: Int {
        get {
            let calendar = Calendar.current
            return calendar.component(.second, from: self)
        }
    }
    
    init?(string: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        if let d = formatter.date(from: string) {
            self = d
        }
        else {
            return nil
        }
    }
    
    init?(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let date = calendar.date(from: components)
        if date == nil {
            return nil
        }
        self = date!
    }
    
    static func from(string: String, format: String) -> Date? {
        return Date(string: string, format: format)
    }
    
    func string(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}

extension UIButton {
    func setBackground(color: UIColor, forState state: UIControlState) -> Void {
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let path = CGPath(roundedRect: rect, cornerWidth: 6, cornerHeight: 4, transform: nil)
        context?.addPath(path)
        context?.setFillColor(color.cgColor)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(white: 0, alpha: 0.65).cgColor)
        context!.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(image, for: state)
    }
}

extension String {
    static func isEmptyOrNil(string: String?) ->Bool {
        if string != nil && !string!.isEmpty {
            return false
        }
        return true
    }
    
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    var dropLast: String {
        return dropLast()
    }
}

class BlockSwitch: UISwitch {
    private var _block: (() ->Void)?
    
    func callActionBlock(_ sender: Any?) -> Void {
        self._block?()
    }
    
    func handle(events: UIControlEvents, with block: @escaping (() ->Void)) -> Void {
        self._block = block
        self.addTarget(self, action: #selector(callActionBlock(_:)), for: events)
    }
}
