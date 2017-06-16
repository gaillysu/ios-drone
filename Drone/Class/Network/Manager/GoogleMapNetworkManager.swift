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
            return (true, json, nil)
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func geocodeAddressString(address:String, responseBlock: @escaping (_ results:[GoogleMapsGeocodeModel]?) -> Void) {
        let request:AddressGeocodeRequest = AddressGeocodeRequest(selectText: address) { (success, json, error) in
            if success {
                let googleModelAray:[GoogleMapsGeocodeModel] = self.geocodeJSONParsing(json: json ?? JSON("[]"))
                responseBlock(googleModelAray)
            }else{
                responseBlock(nil)
            }
        }
        executeMEDRequest(request: request)
    }
    
    func getGoogleMapsDirections(startAddres:String, endAddres:String, mode:String?, responseBlock: @escaping (_ results:GoogleMapsDirectionsModel?) -> Void) {
        let request:GoogleMapsDirectionsRequest = GoogleMapsDirectionsRequest(startLocation: startAddres, endLocation: endAddres, mode: mode) { (success, json, error) in
            if success {
                let googleDirectionsModel:GoogleMapsDirectionsModel  = self.directionsJSONParsing(json: json!)
                responseBlock(googleDirectionsModel)
            }else{
                responseBlock(nil)
            }
        }
        executeMEDRequest(request: request)
    }
    
    fileprivate func geocodeJSONParsing(json:JSON) -> [GoogleMapsGeocodeModel] {
        var googleModelAray:[GoogleMapsGeocodeModel] = []
        let resultsJson:[JSON] = json["results"].arrayValue
        if resultsJson.count>0 {
            resultsJson.forEach({ (jsonValue) in
                let addressComponents:[JSON] = jsonValue["address_components"].arrayValue
                let geometry:JSON = jsonValue["geometry"]
                let googleModel:GoogleMapsGeocodeModel = GoogleMapsGeocodeModel()
                googleModel.formatted_address = jsonValue["formatted_address"].stringValue
                googleModel.geometry_location_lat = geometry["location"]["lat"].stringValue
                googleModel.geometry_location_lng = geometry["location"]["lng"].stringValue
                googleModel.viewport_northeast_lat = geometry["viewport"]["northeast"]["lat"].stringValue
                googleModel.viewport_northeast_lng = geometry["viewport"]["northeast"]["lng"].stringValue
                googleModel.viewport_southwest_lat = geometry["viewport"]["southwest"]["lat"].stringValue
                googleModel.viewport_southwest_lng = geometry["viewport"]["southwest"]["lng"].stringValue
                googleModel.location_type = geometry["location_type"].stringValue
                
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
                    if typesArray == ["country","political"] {
                        googleModel.countryLong_name = addressDict["long_name"]!.stringValue
                        googleModel.countryShort_name = addressDict["short_name"]!.stringValue
                        googleModel.countryTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                    
                    if typesArray == ["administrative_area_level_1","political"] {
                        googleModel.politicalLong_name = addressDict["long_name"]!.stringValue
                        googleModel.politicalShort_name = addressDict["short_name"]!.stringValue
                        googleModel.politicalTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                    
                    if typesArray == ["locality","political"] {
                        googleModel.localityLong_name = addressDict["long_name"]!.stringValue
                        googleModel.localityShort_name = addressDict["short_name"]!.stringValue
                        googleModel.localityTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                    
                    if typesArray == ["political","sublocality","sublocality_level_1"] {
                        googleModel.sublocalityLong_name = addressDict["long_name"]!.stringValue
                        googleModel.sublocalityShort_name = addressDict["short_name"]!.stringValue
                        googleModel.sublocalityTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                    
                    if typesArray == ["route"] {
                        googleModel.routeLong_name = addressDict["long_name"]!.stringValue
                        googleModel.routeShort_name = addressDict["short_name"]!.stringValue
                        googleModel.routeTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                    
                    if typesArray == ["establishment","park","point_of_interest"] {
                        googleModel.parkLong_name = addressDict["long_name"]!.stringValue
                        googleModel.parkShort_name = addressDict["short_name"]!.stringValue
                        googleModel.parkTypes = addressDict["types"]!.arrayValue.first!.stringValue
                    }
                })
                
                googleModelAray.append(googleModel)
            })
        }

        return googleModelAray
    }
    
    func directionsJSONParsing(json:JSON) -> GoogleMapsDirectionsModel {
        let googleDirectionsModel:GoogleMapsDirectionsModel = GoogleMapsDirectionsModel()
        let geocoded_waypoints = json["geocoded_waypoints"].arrayValue
        geocoded_waypoints.forEach { (waypointsJson) in
            let typeArray:[JSON] = waypointsJson["types"].arrayValue
            let waypointsModel:GoogleWaypointsModel = GoogleWaypointsModel()
            waypointsModel.geocoder_status = waypointsJson["geocoder_status"].stringValue
            waypointsModel.place_id = waypointsJson["place_id"].stringValue
            typeArray.forEach({ (typeJson) in
                waypointsModel.types.append(typeJson.stringValue)
            })
            googleDirectionsModel.geocoded_waypoints.append(waypointsModel)
        }
        
        let routes = json["routes"].arrayValue
        routes.forEach { (routesJSON) in
            let bounds:JSON = routesJSON["bounds"]
            let northeast:JSON = bounds["northeast"]
            let southwest:JSON = bounds["southwest"]
            let legs:JSON = routesJSON["legs"].arrayValue.first!
            let distance:JSON = legs["distance"]
            let duration:JSON = legs["duration"]
            let steps:[JSON] = legs["steps"].arrayValue
            
            let routesModel:GoogleMapsRoutesModel = GoogleMapsRoutesModel()
            routesModel.bounds_northeast_lat = northeast["lat"].doubleValue
            routesModel.bounds_northeast_lng = northeast["lng"].doubleValue
            routesModel.bounds_southwest_lat = southwest["lat"].doubleValue
            routesModel.bounds_southwest_lng = southwest["lng"].doubleValue
            routesModel.copyrights = routesJSON["copyrights"].stringValue
            
            routesModel.distance_text = distance["text"].stringValue
            routesModel.distance_value = distance["value"].intValue
            routesModel.duration_text = duration["text"].stringValue
            routesModel.duration_value = duration["value"].intValue
            
            routesModel.start_address = legs["start_address"].stringValue
            routesModel.start_location_lat = legs["start_location"]["lat"].doubleValue
            routesModel.start_location_lng = legs["start_location"]["lng"].doubleValue
            
            routesModel.end_address = legs["end_address"].stringValue
            routesModel.end_location_lat = legs["end_location"]["lat"].doubleValue
            routesModel.end_location_lng = legs["end_location"]["lng"].doubleValue
            
            steps.forEach({ (stepsJSON) in
                let routes:RoutesStepsModel = RoutesStepsModel()
                routes.distance_text = stepsJSON["distance"]["text"].stringValue
                routes.distance_value = stepsJSON["distance"]["value"].intValue
                routes.duration_text = stepsJSON["duration"]["text"].stringValue
                routes.duration_value = stepsJSON["duration"]["value"].intValue
                
                routes.start_location_lat = stepsJSON["start_location"]["lat"].doubleValue
                routes.start_location_lng = stepsJSON["start_location"]["lng"].doubleValue
                
                routes.end_location_lat = stepsJSON["end_location"]["lat"].doubleValue
                routes.end_location_lng = stepsJSON["end_location"]["lng"].doubleValue
                
                routes.html_instructions = stepsJSON["html_instructions"].stringValue
                routes.polyline_points = stepsJSON["polyline"]["points"].stringValue
                routes.travel_mode = stepsJSON["travel_mode"].stringValue
                
                routesModel.routesSteps.append(routes)
            })
            
            routesModel.overview_polyline_points = routesJSON["overview_polyline"]["points"].stringValue
            routesModel.summary =  routesJSON["summary"].stringValue
            routesModel.warnings = routesJSON["warnings"].arrayValue
            routesModel.waypoint_order = routesJSON["waypoint_order"].arrayValue
            
            googleDirectionsModel.routes.append(routesModel)
        }
        
        return googleDirectionsModel
    }
}
