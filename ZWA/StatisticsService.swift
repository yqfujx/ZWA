//
//  StatisticsService.swift
//  ZWA
//
//  Created by osx on 2017/8/14.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

struct StatisticsRow {
    enum Key : String {
        case notOverload = "NoOver"
        case overload = "OverCount"
        case overIn10 = "OverIN10"
        case overIn20 = "OverIN20"
        case overIn30 = "OverIN30"
        case overIn40 = "OverIN40"
        case overIn50 = "OverIN50"
        case overIn60 = "OverIN60"
        case overIn70 = "OverIN70"
        case overIn80 = "OverIN80"
        case overIn90 = "OverIN90"
        case overIn100 = "OverIN100"
        case out100 = "Out100"
    }
    
    var key: Key
    var value: Int
    var indentLevel = 0
    var indivisible = true
    
    init(key: Key, value: Int, indivisible: Bool = true, indentLevel: Int = 0) {
        self.key = key
        self.value = value
        self.indivisible = indivisible
        self.indentLevel = indentLevel
    }
    
    var description: String {
        get {
            var desc: String?
            
            switch key {
            case .notOverload:
                desc = "未超载"
            case .overload:
                desc = "超载"
            case .overIn10:
                desc = "超载率 <= 10%"
            case .overIn20:
                desc = "超载率 <= 20%"
            case .overIn30:
                desc = "超载率 <= 30%"
            case .overIn40:
                desc = "超载率 <= 40%"
            case .overIn50:
                desc = "超载率 <= 50%"
            case .overIn60:
                desc = "超载率 <= 60%"
            case .overIn70:
                desc = "超载率 <= 70%"
            case .overIn80:
                desc = "超载率 <= 80%"
            case .overIn90:
                desc = "超载率 <= 90%"
            case .overIn100:
                desc = "超载率 <= 100%"
            case .out100:
                desc = "超载率 > 100%"
            default:
                desc = "未知"
            }
            
            return desc!
        }
    }
}

struct StatisticsSection {
    var description: String
    var overloadNum: Int
    var notOverloadNum: Int
    var rows: [StatisticsRow]?
}

struct StatisticsData {
    var key: StatisticsKey
    var sections: [StatisticsSection]?
}

class StatisticsService: NSObject {
    
    private var _sendQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Statistics Service Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var data: StatisticsData?

    func statisticWith(stationID: String, key: String, timeSpan: String, time: Date, completion: ((Bool, SysError?) ->Void)?) -> Void {
        let request = Request.statistic(stationID, key, timeSpan, time, ServiceCenter.currentAccount!.token!)
        
        self._sendQueue.addOperation { () in
            _ = ServiceCenter.network?.send(request: request, completion: { [weak self] (success: Bool, dictionary: [String : Any]?, error: SysError?) in
                guard let _self = self else {
                    return
                }
                
                var success = success
                var error = error
                
                if success {
                    var data: StatisticsData?
                    do {
                        data = try _self.parse(dictionary: dictionary!)
                    }
                    catch let e {
                        success = false
                        error = e as? SysError
                    }
                    
                    DispatchQueue.main.async {
                        _self.data = data
                        completion?(success, error)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion?(false, error)
                    }
                }
            })
        }
    }
    
    func parse(dictionary: [String: Any]) throws -> StatisticsData? {
        var key: StatisticsKey?
        
        if let keyValue = dictionary["flag"] as? String {
            key = StatisticsKey(rawValue: keyValue.lowercased())
        }
        else {
            throw SysError(domain: ErrorDomain.statisticsService, code: ErrorCode.badData)
        }
        
        let sectionData = dictionary["Table"] as! [Any]
        var sections: [StatisticsSection]?
        
        switch key! {
        case .axle:
            sections = try self.parseAxleData(data: sectionData)
        case .lane:
            sections = try self.parseLaneData(data: sectionData)
        case .overload:
            sections = try self.parseOverloadData(data: sectionData)
        case .rate:
            sections = try self.parseRateData(data: sectionData)
        }
        
        let data = StatisticsData(key: key!, sections: sections)
        return data
    }
    
    func parseAxleData(data: [Any]) throws -> [StatisticsSection]? {
        var sections = [StatisticsSection]()
        
        for sectionItem in data {
            guard let sectionItem = sectionItem as? [String: Any],
                let description = sectionItem["carAxisa"] as? String,
                let overloadNum = sectionItem["OverCount"] as? Int,
                let notOverloadNum = sectionItem["NoOver"] as? Int else {
                    throw SysError(domain: ErrorDomain.statisticsService, code: ErrorCode.badData)
            }
            
            var section = StatisticsSection(description: description, overloadNum: overloadNum, notOverloadNum: notOverloadNum, rows: nil)
            var rows = [StatisticsRow]()
            
            rows.append(StatisticsRow(key: .notOverload, value: notOverloadNum))
            rows.append(StatisticsRow(key: .overload, value: overloadNum, indivisible: false))
           
            if let value = sectionItem["OverIN10"] as? Int {
                let row = StatisticsRow(key: .overIn10, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN20"] as? Int {
                let row = StatisticsRow(key: .overIn20, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN30"] as? Int {
                let row = StatisticsRow(key:.overIn30, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN40"] as? Int {
                let row = StatisticsRow(key: .overIn40, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN50"] as? Int {
                let row = StatisticsRow(key: .overIn50, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN60"] as? Int {
                let row = StatisticsRow(key: .overIn60, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN70"] as? Int {
                let row = StatisticsRow(key: .overIn70, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN80"] as? Int {
                let row = StatisticsRow(key: .overIn80, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN90"] as? Int {
                let row = StatisticsRow(key: .overIn90, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN100"] as? Int {
                let row = StatisticsRow(key: .overIn100, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["Out100"] as? Int {
                let row = StatisticsRow(key: .out100, value: value, indentLevel: 3)
                rows.append(row)
            }
            
            section.rows = rows
            sections.append(section)
        }
        
        return sections
    }
    
    func parseLaneData(data: [Any]) throws -> [StatisticsSection]? {
        var sections = [StatisticsSection]()
        
        for sectionItem in data {
            guard let sectionItem = sectionItem as? [String: Any],
                let description = sectionItem["carlan"] as? String,
                let overloadNum = sectionItem["OverCount"] as? Int,
                let notOverloadNum = sectionItem["NoOver"] as? Int else {
                    throw SysError(domain: ErrorDomain.statisticsService, code: ErrorCode.badData)
            }
            
            var section = StatisticsSection(description: description + "车道", overloadNum: overloadNum, notOverloadNum: notOverloadNum, rows: nil)
            var rows = [StatisticsRow]()
            
            rows.append(StatisticsRow(key: .notOverload, value: notOverloadNum))
            rows.append(StatisticsRow(key: .overload, value: overloadNum, indivisible: false))
            
            if let value = sectionItem["OverIN10"] as? Int {
                let row = StatisticsRow(key: .overIn10, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN20"] as? Int {
                let row = StatisticsRow(key: .overIn20, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN30"] as? Int {
                let row = StatisticsRow(key:.overIn30, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN40"] as? Int {
                let row = StatisticsRow(key: .overIn40, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN50"] as? Int {
                let row = StatisticsRow(key: .overIn50, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN60"] as? Int {
                let row = StatisticsRow(key: .overIn60, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN70"] as? Int {
                let row = StatisticsRow(key: .overIn70, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN80"] as? Int {
                let row = StatisticsRow(key: .overIn80, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN90"] as? Int {
                let row = StatisticsRow(key: .overIn90, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN100"] as? Int {
                let row = StatisticsRow(key: .overIn100, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["Out100"] as? Int {
                let row = StatisticsRow(key: .out100, value: value, indentLevel: 3)
                rows.append(row)
            }
            
            section.rows = rows
            sections.append(section)
        }
        
        return sections
    }
    
    func parseOverloadData(data: [Any]) throws -> [StatisticsSection]? {
        var sections = [StatisticsSection]()
        
        for sectionItem in data {
            guard let sectionItem = sectionItem as? [String: Any],
                let overloadNum = sectionItem["OverCount"] as? Int,
                let notOverloadNum = sectionItem["NoOver"] as? Int else {
                    throw SysError(domain: ErrorDomain.statisticsService, code: ErrorCode.badData)
            }
            
            let description = "超载统计"
            var section = StatisticsSection(description: description, overloadNum: overloadNum, notOverloadNum: notOverloadNum, rows: nil)
            var rows = [StatisticsRow]()
            
            rows.append(StatisticsRow(key: .notOverload, value: notOverloadNum))
            rows.append(StatisticsRow(key: .overload, value: overloadNum))
            
            if let value = sectionItem["OverIN10"] as? Int {
                let row = StatisticsRow(key: .overIn10, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN20"] as? Int {
                let row = StatisticsRow(key: .overIn20, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN30"] as? Int {
                let row = StatisticsRow(key:.overIn30, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN40"] as? Int {
                let row = StatisticsRow(key: .overIn40, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN50"] as? Int {
                let row = StatisticsRow(key: .overIn50, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN60"] as? Int {
                let row = StatisticsRow(key: .overIn60, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN70"] as? Int {
                let row = StatisticsRow(key: .overIn70, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN80"] as? Int {
                let row = StatisticsRow(key: .overIn80, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN90"] as? Int {
                let row = StatisticsRow(key: .overIn90, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN100"] as? Int {
                let row = StatisticsRow(key: .overIn100, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["Out100"] as? Int {
                let row = StatisticsRow(key: .out100, value: value, indentLevel: 3)
                rows.append(row)
            }
            
            section.rows = rows
            sections.append(section)
        }
        
        return sections
    }
    
    func parseRateData(data: [Any]) throws -> [StatisticsSection]? {
        var sections = [StatisticsSection]()
        
        for sectionItem in data {
            guard let sectionItem = sectionItem as? [String: Any],
                let overloadNum = sectionItem["OverCount"] as? Int,
                let notOverloadNum = sectionItem["NoOver"] as? Int else {
                    throw SysError(domain: ErrorDomain.statisticsService, code: ErrorCode.badData)
            }
            
            let description = "超载率统计"
            var section = StatisticsSection(description: description, overloadNum: overloadNum, notOverloadNum: notOverloadNum, rows: nil)
            var rows = [StatisticsRow]()
            
            rows.append(StatisticsRow(key: .notOverload, value: notOverloadNum))
            rows.append(StatisticsRow(key: .overload, value: overloadNum, indivisible: false))
            
            if let value = sectionItem["OverIN10"] as? Int {
                let row = StatisticsRow(key: .overIn10, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN20"] as? Int {
                let row = StatisticsRow(key: .overIn20, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN30"] as? Int {
                let row = StatisticsRow(key:.overIn30, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN40"] as? Int {
                let row = StatisticsRow(key: .overIn40, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN50"] as? Int {
                let row = StatisticsRow(key: .overIn50, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN60"] as? Int {
                let row = StatisticsRow(key: .overIn60, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN70"] as? Int {
                let row = StatisticsRow(key: .overIn70, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN80"] as? Int {
                let row = StatisticsRow(key: .overIn80, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN90"] as? Int {
                let row = StatisticsRow(key: .overIn90, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["OverIN100"] as? Int {
                let row = StatisticsRow(key: .overIn100, value: value, indentLevel: 3)
                rows.append(row)
            }
            if let value = sectionItem["Out100"] as? Int {
                let row = StatisticsRow(key: .out100, value: value, indentLevel: 3)
                rows.append(row)
            }
            
            section.rows = rows
            sections.append(section)
        }
        
        return sections
    }
    
    deinit {
        self._sendQueue.cancelAllOperations()
    }
}
