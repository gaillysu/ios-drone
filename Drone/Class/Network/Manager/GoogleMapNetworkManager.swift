//
//  GoogleMapNetworkManager.swift
//  Drone
//
//  Created by Cloud on 2017/6/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleMapNetworkManager: NSObject {
    fileprivate static let baseURL = "https://maps.googleapis.com"
    static let manager:GoogleMapNetworkManager = GoogleMapNetworkManager()
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate func executeMEDRequest(request :NetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = GoogleMapNetworkManager.baseURL + urlPart
            Alamofire.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: request.headers).responseJSON(completionHandler: { response in
                let result = self.isValidResponse(response: response)
                request.response(result.success, result.json, result.error)
            })
            
        }else{
            print("URL/METHOD/ENCODING IS WRONGLY/NOT SPECIFIED IN THE REQUEST. DID NOT EXECUTE NETWORK REQUEST!")
        }
    }
    
    fileprivate func isValidResponse(response:DataResponse<Any>) -> (success:Bool, json:JSON?, error:Error?) {
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            if(json["results"].arrayValue.count == 0){
                return (false,json, nil)
            }else{
                return (true, json, nil)
            }
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func geocodeAddressString(address:String, responseBlock: @escaping (_ results:[GoogleMapsModel]?) -> Void) {
        let request:AddressGeocodeRequest = AddressGeocodeRequest(selectText: address) { (success, json, error) in
            if success {
                var googleModelAray:[GoogleMapsModel] = []
                let resultsJson:[JSON] = json!["results"].arrayValue
                resultsJson.forEach({ (jsonValue) in
                    let addressComponents:[JSON] = jsonValue["address_components"].arrayValue
                    let geometry:[String:JSON] = jsonValue["geometry"].dictionaryValue
                    let googleModel:GoogleMapsModel = GoogleMapsModel()
                    googleModel.formatted_address = jsonValue["formatted_address"].stringValue
                    googleModel.geometry_location_lat = geometry["location"]!.dictionaryValue["lat"]!.stringValue
                    googleModel.geometry_location_lng = geometry["location"]!.dictionaryValue["lng"]!.stringValue
                    googleModel.viewport_northeast_lat = geometry["viewport"]!.dictionaryValue["northeast"]!.dictionaryValue["lat"]!.stringValue
                    googleModel.viewport_northeast_lng = geometry["viewport"]!.dictionaryValue["northeast"]!.dictionaryValue["lng"]!.stringValue
                    googleModel.viewport_southwest_lat = geometry["viewport"]!.dictionaryValue["southwest"]!.dictionaryValue["lat"]!.stringValue
                    googleModel.viewport_southwest_lng = geometry["viewport"]!.dictionaryValue["southwest"]!.dictionaryValue["lng"]!.stringValue
                    googleModel.location_type = geometry["location_type"]!.stringValue
                    
                    googleModel.place_id = jsonValue["place_id"].stringValue
                    jsonValue["types"].arrayValue.forEach({ (typesJSON) in
                        googleModel.types.append(typesJSON.stringValue)
                    })
                    
                    addressComponents.forEach({ (addressJSON) in
                        let addressDict:[String:JSON] = addressJSON.dictionaryValue
                        var typesArray:[String] = []
                        addressDict["types"]!.arrayValue.forEach({ (type) in
                            typesArray.append(type.stringValue)
                        })
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"country\",\"political\"]")) {
                            googleModel.countryLong_name = addressDict["long_name"]!.stringValue
                            googleModel.countryShort_name = addressDict["short_name"]!.stringValue
                            googleModel.countryTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                        
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"administrative_area_level_1\",\"political\"]")) {
                            googleModel.politicalLong_name = addressDict["long_name"]!.stringValue
                            googleModel.politicalShort_name = addressDict["short_name"]!.stringValue
                            googleModel.politicalTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                        
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"locality\",\"political\"]")) {
                            googleModel.localityLong_name = addressDict["long_name"]!.stringValue
                            googleModel.localityShort_name = addressDict["short_name"]!.stringValue
                            googleModel.localityTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                        
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"political\",\"sublocality\",\"sublocality_level_1\"]")) {
                            googleModel.sublocalityLong_name = addressDict["long_name"]!.stringValue
                            googleModel.sublocalityShort_name = addressDict["short_name"]!.stringValue
                            googleModel.sublocalityTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                        
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"route\"]")) {
                            googleModel.routeLong_name = addressDict["long_name"]!.stringValue
                            googleModel.routeShort_name = addressDict["short_name"]!.stringValue
                            googleModel.routeTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                        
                        if addressDict["types"]!.arrayValue.contains(JSON("[\"establishment\",\"park\",\"point_of_interest\"]")) {
                            googleModel.parkLong_name = addressDict["long_name"]!.stringValue
                            googleModel.parkShort_name = addressDict["short_name"]!.stringValue
                            googleModel.parkTypes = addressDict["types"]!.arrayValue.first!.stringValue
                        }
                    })
                    
                    googleModelAray.append(googleModel)
                })
                
                responseBlock(googleModelAray)
            }else{
                responseBlock(nil)
            }
        }
        executeMEDRequest(request: request)
    }
}
