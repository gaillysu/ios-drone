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
    fileprivate static let baseUrl = "http://a.kendy.com.hk"
    
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
    
    class func updateOtaVersion(completion:@escaping ((_ version:Double, _ description:String, _ date:Date, _ fileName:String) -> Void), error:@escaping ((_ error:Error) -> Void)){
        Alamofire.request(URL(string: "\(baseUrl)/firmware.json")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                if response.result.error == nil {
                    let response = JSON(response.result.value as? NSDictionary ?? [:])
                    if let version = response["version"].double, let description = response["description"].string, let _ = response["date"].string, let filename = response["filename"].string {
                        
                        DTUserDefaults.lastOtaVersionCheck = Date()
                        DTUserDefaults.lastKnownOtaVersion = Double(version)
                        completion(version, description, Date(), filename)
                    }else{
                        print("Could not parse stuff correctly.")
                        print(response)
                    }
                }else{
                    error(response.result.error!)
                }
        }
    }
    
    class func getOtaFile(version:Double, filename:String, process:@escaping((_ progres:Double) -> Void), completion:@escaping ((_ path:URL) -> Void), error:@escaping ((_ error:Error) -> Void)){
        let storage = FirmwareStorage()
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (storage.generateUrlFor(version: version).absolute, [.createIntermediateDirectories, .removePreviousFile])
        }
        Alamofire.download("\(baseUrl)/\(filename)", to: destination)
            .downloadProgress { process($0.fractionCompleted) }
            .responseData { response in
                if let _ = response.result.value {
                    completion(storage.generateUrlFor(version: version).absolute)
                }else if let errorVal = response.error{
                    error(errorVal)
                }
        }
    }
}
