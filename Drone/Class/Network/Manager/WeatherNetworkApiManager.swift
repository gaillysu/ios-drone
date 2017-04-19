//
//  WeatherNetworkApiManager.swift
//  Drone
//
//  Created by Cloud on 2017/4/18.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherNetworkApiManager: NSObject {
    
    fileprivate static let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    static let manager:WeatherNetworkApiManager = WeatherNetworkApiManager()
    
    fileprivate var tempValue:Int = 0
    fileprivate var weatherStatusText:String = ""

    fileprivate override init() {
        super.init()
    }
    
    fileprivate func executeMEDRequest(request :NetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = WeatherNetworkApiManager.baseURL + urlPart
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
            if(json["count"].intValue != 1){
                return (false,json, nil)
            }else{
                return (true, json, nil)
            }
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func getWeatherInfo(regionName:String,responseBlock: @escaping (_ temp:Int, _ code:Int, _ statusText:String?) -> Void) {
        let weatherRequest:WeatherInfoRequest = WeatherInfoRequest(selectText: "") { (success, json, error) in
            if success {
                if let weatherJSON = json {
                    let weatherInfo:[String:JSON] = weatherJSON.dictionaryValue
                    let weather:[String:JSON] = weatherInfo["weather"]!.arrayValue.first!.dictionaryValue
                    let main:[String:JSON] = weatherInfo["main"]!.dictionaryValue
                    
                    let temp:Int = main["temp"]!.intValue
                    let code:Int = weather["id"]!.intValue
                    let text:String = weather["main"]!.stringValue
                    
                    self.tempValue = temp-273
                    self.weatherStatusText = text
                    responseBlock(self.tempValue , code, self.weatherStatusText)
                }else{
                    responseBlock(0, 0, nil);
                }
            }else{
                responseBlock(0, 0, nil)
            }
        }
        executeMEDRequest(request: weatherRequest)
    }
    
    func getWeatherStatusCode(code:Int) -> WeatherStatusIcon {
        if [800].contains(code) {
            return WeatherStatusIcon.clearNight;
        }
        
        if [801].contains(code) {
            return WeatherStatusIcon.partlyCloudyNight
        }
        
        if [802,803,804].contains(code) {
            return WeatherStatusIcon.cloudy
        }
        
        if [900].contains(code) {
            return WeatherStatusIcon.tornado
        }
        
        if [901].contains(code) {
            return WeatherStatusIcon.typhoon
        }
        
        if [902].contains(code) {
            return WeatherStatusIcon.hurricane
        }
        
        if [905].contains(code) || (code >= 952 && code<=959){
            return WeatherStatusIcon.windy;
        }
        
        if [960,200,201,202,210,211,212,221,230,231,232].contains(code) {
            return WeatherStatusIcon.stormy;
        }
        
        if [600,601,602,611,612,615,616,620,621,622].contains(code) {
            return WeatherStatusIcon.snow;
        }
        
        if [701,711,721,741,761].contains(code) {
            return WeatherStatusIcon.fog;
        }
        
        if [300,301,302,310,311,500].contains(code) {
            return WeatherStatusIcon.rainLight;
        }
        
        if [312,313,314,321,501,502,503,504,511,520,521,522,531].contains(code) {
            return WeatherStatusIcon.rainHeavy;
        }
        
        return WeatherStatusIcon.invalidData
    }
}
