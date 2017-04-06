//
//  ServiceSubscriberProtocol.swift
//  ZWA
//
//  Created by mac on 2017/4/1.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import Foundation

protocol ServiceSubscriberProtocol {
    func subscriberService(service: AnyObject) -> Void
    func notification(of: AnyObject, named: String) -> Void
}
