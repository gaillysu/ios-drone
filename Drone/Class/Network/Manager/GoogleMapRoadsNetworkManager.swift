//
//  GoogleMapRoadsNetworkManager.swift
//  Drone
//
//  Created by Cloud on 2017/6/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleMapRoadsNetworkManager: NSObject {
    fileprivate static let baseURL = "https://roads.googleapis.com"
    static let manager:GoogleMapRoadsNetworkManager = GoogleMapRoadsNetworkManager()
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate func executeMEDRequest(request :NetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = GoogleMapRoadsNetworkManager.baseURL + urlPart
            let datarequest = Alamofire.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: request.headers).responseJSON(completionHandler: { response in
                let result = self.isValidResponse(response: response)
                request.response(result.success, result.json, result.error)
            })
            //print("request:\(datarequest.request?.url)")
        }else{
            print("URL/METHOD/ENCODING IS WRONGLY/NOT SPECIFIED IN THE REQUEST. DID NOT EXECUTE NETWORK REQUEST!")
        }
    }
    
    fileprivate func isValidResponse(response:DataResponse<Any>) -> (success:Bool, json:JSON?, error:Error?) {
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            return (true, json, nil)
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func snaptoRoadsRequest(path:String, responseBlock: @escaping (_ results:[GoogleSnapRoadsModel]?) -> Void) {
        let request:GoogleMapSnaptoRoadsRequest = GoogleMapSnaptoRoadsRequest(path: path) { (success, json, error) in
            if success {
                responseBlock(self.snapRoadsJSONParsing(json: json!))
            }else{
                responseBlock(nil)
            }
        }
        executeMEDRequest(request: request)
    }
    
    fileprivate func snapRoadsJSONParsing(json:JSON) -> [GoogleSnapRoadsModel] {
        var snapRoadsArray:[GoogleSnapRoadsModel] = []
        
        let snapRoads = json["snappedPoints"].arrayValue
        snapRoads.forEach { (roadsJson) in
            let snapRoadsModel:GoogleSnapRoadsModel = GoogleSnapRoadsModel()
            let location = roadsJson["location"]
            snapRoadsModel.location_latitude = location["latitude"].doubleValue
            snapRoadsModel.location_longitude = location["longitude"].doubleValue
            snapRoadsModel.originalIndex = roadsJson["originalIndex"].intValue
            snapRoadsModel.placeId = roadsJson["placeId"].stringValue
            snapRoadsArray.append(snapRoadsModel)
        }
        return snapRoadsArray
    }
}
