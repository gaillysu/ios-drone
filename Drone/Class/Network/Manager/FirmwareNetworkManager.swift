//
//  FirmwareNetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 14/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FirmwareNetworkManager: NSObject {
    fileprivate static let baseUrl = "ftp://ftp.dayton.com.hk:21"
    
    fileprivate lazy var networkState: NetworkReachabilityManager = {
        let network:NetworkReachabilityManager = NetworkReachabilityManager(host: baseUrl)!
        return network
    }()
    
    fileprivate override init() {
        super.init()
        networkState.startListening()
        networkState.listener = { status in
            debugPrint("Network Status Changed: \(status)")
        }
    }
    
    func getNetworkState() -> Bool {
        return networkState.isReachable
    }
    
    class func updateOtaVersion(completion:@escaping ((_ version:Int, _ description:String, _ date:Date, _ fileName:String) -> Void), error:@escaping ((_ error:Error) -> Void)){
        
        Alamofire.download("\(baseUrl)/firmware.json", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .authenticate(user: "apps_upload", password: "4BPEJJa6")
            .responseJSON { response in
                if response.result.error == nil {
                    let response = JSON(response.result.value as? NSDictionary ?? [:])
                    if let version = response["version"].int, let description = response["description"].string, let dateString = response["date"].string, let filename = response["filename"].string {
                        guard let date = dateString.dateFromISO8601 else{
                            fatalError("Date is not according to ISO8601")
                        }
                        DTUserDefaults.lastOtaVersionCheck = Date()
                        DTUserDefaults.lastKnownOtaVersion = Float(version)
                        completion(version, description, date, filename)
                    }else{
                        fatalError("Wrongly parsed JSON file.")
                    }
                }else{
                    error(response.result.error!)
                }
        }
    }
    
    class func getOtaFile(filename:String, process:@escaping((_ progres:Double) -> Void), completion:@escaping ((_ otaDataFile:Data) -> Void), error:@escaping ((_ error:Error) -> Void)){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let file = directoryURL.appendingPathComponent("", isDirectory: false)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        Alamofire.download("\(baseUrl)/\(filename)", to: destination)
            .authenticate(user: "apps_upload", password: "4BPEJJa6")
            .downloadProgress { process($0.fractionCompleted) }
            .responseData { response in
                if let data = response.result.value {
                    completion(data)
                }else if let errorVal = response.error{
                    error(errorVal)
                }
        }
    }
}
