//
//  PhotoService.swift
//  ZWA
//
//  Created by osx on 2017/8/9.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

enum PhotoRecordState {
    case new, downloaded, failed
}

fileprivate let thumbNailSize = CGSize(width: 120, height: 90)
fileprivate var photoDirectory: String {
    get {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let directory = (documentsDirectory as NSString).appendingPathComponent("images")
        
        return directory
    }
}


class PhotoRecord {
    let url: String
    var state = PhotoRecordState.new
    var thumbnail = UIImage(named: "image_placeholder.png")
    var image: UIImage?
    var fileName: String?
    
    init(url: String) {
        self.url = url
    }
}

class PhotoRepository {
    private var _db: Database!
    let dbName = "images"
    private var _cache = [String: PhotoRecord]()
    
    init(db: Database) {
        self._db = db
        db.inTransaction { [unowned self] (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            if !db!.tableExists(self.dbName) {
                let sql = "CREATE TABLE \(self.dbName) (" +
                "`url` TEXT, " +
                 "`file_name` TEXT, " +
                "PRIMARY KEY (`url`)" +
                ")"
                db?.executeStatements(sql)
            }
        }
    }
    
    func reset() -> Void {
        self._cache.removeAll()
    }
    
    func record(forUrl url: String) ->PhotoRecord? {
        var record = self._cache[url]
        
        if record == nil {
            self._db.inTransaction { [unowned self] (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
                let sql = "SELECT `file_name` FROM \( self.dbName) WHERE (`url`=?)"
                if let rs = db?.executeQuery(sql, withArgumentsIn: [url]) {
                    while rs.next() {
                        record = PhotoRecord(url: url)
                        if let fileName = rs.string(forColumnIndex: 0) {
                            let path = (photoDirectory as NSString).appendingPathComponent(fileName)
                            let image = UIImage(contentsOfFile: path)
                            
                            record?.image = image
                            record?.thumbnail = image?.thumbImage(with: thumbNailSize, gravity: kCAGravityResizeAspectFill)
                            record?.state = .downloaded
                        }
                        self._cache[url] = record
                    }
                }
            }
        }
        
        return record
    }
    
    func update(record: PhotoRecord) -> Void {
        if record.state == .downloaded {
            self._db.inTransaction { [unowned self] (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
                let sql = "INSERT OR REPLACE INTO \(self.dbName) (`url`, `file_name`) VALUES(?, ?)"
                db?.executeUpdate(sql, withArgumentsIn: [record.url, record.fileName!])
            }
        }
        
        self._cache[record.url] = record
    }
}

class ImageDownloader: Operation {
    var record: PhotoRecord!
    
    
    func generateLocalPath() -> String {
        let now = Int64(Date.timeIntervalSinceReferenceDate)
        let rand = Int64(arc4random())
        let string = (photoDirectory as NSString).appendingPathComponent(String(format: "%ld_%ld.jpg", now, rand))
        
        return  string
    }

    init(record: PhotoRecord) {
        self.record = record
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        let imageData = try? Data(contentsOf: URL(string: self.record.url)!)
        
        if self.isCancelled {
            return
        }
        
        if let length = imageData?.count, length > 0 {
            let localPath = self.generateLocalPath()
            
            do {
                let url = URL(fileURLWithPath: localPath)
                try imageData?.write(to: url)
            } catch let e {
                debugPrint("\(#file) \(#line) \(e.localizedDescription)")
            }
            let image = UIImage(data: imageData!)
            
            self.record.fileName = (localPath as NSString).lastPathComponent
            self.record.image = image
            self.record.thumbnail = image?.thumbImage(with: thumbNailSize, gravity: kCAGravityResizeAspectFill)
            self.record.state = .downloaded
        }
        else {
            self.record.state = .failed
        }
    }
}

class PhotoService: NSObject {

    private let _repository = PhotoRepository(db: ServiceCenter.privateDb!)
    private lazy var _progress = [String: ImageDownloader]()
    private lazy var _operationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "image download queue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    override init() {
        let directory = photoDirectory
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    deinit {
        self.stop()
    }
    
    func record(forUrl url: String) -> PhotoRecord {
        if let record = self._repository.record(forUrl: url) {
            return record
        }
        else {
            return PhotoRecord(url: url)
        }
    }
    
    func download(record: PhotoRecord, completion: ((PhotoRecord) ->Void)?) ->Void {
        if self._progress[record.url] != nil {
            return
        }
        
        let downloader = ImageDownloader(record: record)
        downloader.completionBlock = { [weak downloader, weak self] () in
            guard let downloader = downloader, let _self = self else {
                return
            }
            
            if downloader.isCancelled {
                return
            }
            
            let record = downloader.record!
            
            DispatchQueue.main.sync {
                _self._repository.update(record: record)
                _self._progress.removeValue(forKey: record.url)
                completion?(record)
            }
        }
        self._progress[record.url] = downloader
        self._operationQueue.addOperation(downloader)
    }
    
    func stop() -> Void {
        self._operationQueue.cancelAllOperations()
    }
}
