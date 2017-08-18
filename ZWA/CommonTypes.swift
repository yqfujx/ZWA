//
//  CommonTypes.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


let pushNotification = "pushNotification"
let logoutNotification = "logoutNotification"

protocol DescriptiveObject {
    var description: String { get }
}

extension String: DescriptiveObject {
}

/**
 定义服务器信息
 */
struct ServerStruct {
    var id: String!
    var name: String!
    var url: String!
    
    init?(id: String?, name: String?, url: String?) {
        guard !String.isEmptyOrNil(string: id) && !String.isEmptyOrNil(string: name) && !String.isEmptyOrNil(string: url) else {
            return nil
        }
        
        var lowcase = url!.lowercased()
        if lowcase.hasSuffix("?wsdl") {
            lowcase = String(lowcase.characters.dropLast(5))
        }
        self.name = name!
        self.url = lowcase
    }
}

/**
 账户信息
 */
struct Account {
    var serverUrl: String
    var userID: String
    var password: String
    var phone: String?
    var token: String?
    var stations:[Station]?
    
    var dictionary: [String: Any] {
        get {
            var dic: [String:Any] = ["serverUrl": self.serverUrl, "userID": self.userID, "password": self.password]
            if let phone = self.phone {
                dic["phone"] = phone
            }
            if let token = self.token {
                dic["token"] = token
            }
            if let stations = self.stations {
                dic["stations"] = stations
            }
            
            return dic
        }
    }
    
    init(serverUrl: String, userID: String, password: String, phone: String? = nil, token: String? = nil, stations: [Station]? = nil) {
        
        self.serverUrl = serverUrl
        self.userID = userID
        self.password = password
        self.phone = phone
        self.token = token
        self.stations = stations
    }
}

/**
 站点信息
 */
struct Station: DescriptiveObject {
    let zoneID: String
    let stationID: String
    let stationName: String
    var description: String {
        get {
            return self.stationName
        }
    }
}

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    
}


/**
 定义请求
 */
enum Request {
    case servers
    case login(String, String, String?)
    case liveData(Date, Date, Int, String)
    case recentLiveData(String, Int, String)
    case search(Int, String, String?, String?, Int?, Int?, Int?, String?, Date?, Date?)
    case statistic(String, String, String, Date, String)
    
    var api: (HttpMethod, String, [String: Any]?) {
        let method = HttpMethod.POST
        var path = ""
        var params: [String: Any]?
        
        switch self {
        case .servers:
            path = "AreaUrlJsStr"
        case .login(let userID, let password, let pushToken):
            path = "loginUserIos"
            params = ["logid": userID, "pwd": password, "devicemac": pushToken ?? ""]
            
        case .recentLiveData(let userID, let count, let token):
            path = "AreaIllegalIOS"
            params = ["logid": userID, "num": count, "token": token]
            
        case .liveData(let since, let end, let page,  let token):
            path = "conditonSQL"
            params = ["starttime": since.string(with: "yyyy-MM-dd HH:mm:ss"), "endtime": end.string(with: "yyyy-MM-dd HH:mm:ss"), "selectpage": page, "token": token]
            params?["stationid"] = ""
            params?["carno"] = ""
            params?["overwtratelow"] = ""
            params?["overwtratehigh"] = ""
            params?["overflag"] = ""
            params?["carlane"] = ""
            
        case .search(let page,  let token, let stationID, let vehicleID, let overRateLower, let overRateUpper, let overloadStatus, let lane, let earliestTime, let lastTime):
            path = "conditonSQL"
            params = ["selectpage": page, "token": token]
            params?["stationid"] = stationID ?? ""
            params?["carno"] = vehicleID ?? ""
            params?["overwtratelow"] = overRateLower ?? ""
            params?["overwtratehigh"] = overRateUpper ?? ""
            if let overloadStatus = overloadStatus {
                params?["overflag"] = (overloadStatus == 0 ? "overwt" : "noover")
            }
            else {
                params?["overflag"] = ""
            }
            params?["carlane"] = lane ?? ""
            params?["starttime"] = (earliestTime != nil) ? earliestTime?.string(with: "yyyy-MM-dd HH:mm:ss") : ""
            params?["endtime"] = (lastTime != nil) ? lastTime?.string(with: "yyyy-MM-dd HH:mm:ss") : ""
            
        case .statistic(let stationID, let key, let timeSpan, let date, let token):
            path = "CountSQLIOS"
            params = ["stationid": stationID, "sqltime": date.string(with: "yyyy-MM-dd"), "timeflag": timeSpan, "sqlorderby": key, "token": token]
//        default:
//            break
        }
        
        return (method, path, params)
    }
}

class SysError: NSError {
    override init(domain: String, code: Int, userInfo dict: [AnyHashable : Any]? = nil) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    
    convenience init(error: NSError) {
        self.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var localizedDescription: String {
        get {
            var string = ErrorCode.localizedDescription(code: self.code)
            
            if String.isEmptyOrNil(string: string) {
                string = super.localizedDescription
            }
            
            return string!
        }
    }
}

// MARK: - 以下定义错误处理相关常量

struct ErrorDomain {
    static let networkService = "NetworkService"
    static let routerService = "RouterService"
    static let authorizationService = "AuthorizationService"
    static let liveDataService = "LiveDataService"
    static let statisticsService = "StatisticsService"
}

struct ErrorCode {
    static let badData = 1001
    static let loginFailed = 2001
    
    static func localizedDescription(code: Int) ->String? {
        var string: String?
        
        switch code {
        case self.badData:
            string = "数据格式不正确"
        case self.loginFailed:
            string = "登录失败"
        default:
            break
        }
        
        return string
    }
}

enum StatisticsTimeSpan: String, DescriptiveObject {
    case day = "sd"
    case week = "sz"
    case month = "sm"
    case year = "sy"
    
    var description: String {
        get {
            switch self {
            case .day:
                return "统计当日"
            case .week:
                return "统计当周"
            case .month:
                return "统计当月"
            case .year:
                return "统计当年"
            }
        }
    }
}

enum StatisticsKey: String, DescriptiveObject {
    case axle = "zs"
    case lane = "cd"
    case overload = "cz"
    case rate = "czl"
    
    var description: String {
        get {
            switch self {
            case .axle:
                return "按轴数统计"
            case .lane:
                return "按车道统计"
            case .overload:
                return "按超载统计"
            case .rate:
                return "按超载率统计"
            }
        }
    }
}
