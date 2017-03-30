//
//  ResponseXMLParserDelegate.swift
//  ZWA
//
//  Created by mac on 2017/3/28.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ResponseXMLParserDelegate: NSObject, XMLParserDelegate {
    
    private let keyElementName: String
    private var _elementValue: String!
    var elementValue: String? {
        return _elementValue
    }
    
    private var complete = false
    
    init(parser: XMLParser, keyElementName: String) {
        self.keyElementName = keyElementName
        
        super.init()
        parser.delegate = self
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == self.keyElementName {
            _elementValue = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.elementValue != nil {
            _elementValue = _elementValue! + string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == self.keyElementName && self.elementValue != nil{
            self.complete = true
        }
    }
}
