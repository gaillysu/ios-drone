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

let SYNC_WEATHER_INFOKEY = "SYNC_WEATHER_INFOKEY"

class WeatherNetworkApiManager: NSObject {
    
    fileprivate static let baseURL = "https://api.darksky.net/forecast/"
    static let manager:WeatherNetworkApiManager = WeatherNetworkApiManager()
    
    fileprivate var cityid:[Int:(String,Double,Double)] = [:]
    
    fileprivate var tempValue:Int = 0
    fileprivate var weatherStatusText:String = ""
    
    fileprivate lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
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
            if(json["hourly"].dictionaryValue.count == 0){
                return (false,json, nil)
            }else{
                return (true, json, nil)
            }
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func getWeatherInfo(coordinate:(cityName:String, latitude: Double, longitude: Double), id:Int, responseBlock: @escaping (_ id:Int,_ temp:Int, _ icon:WeatherIcon) -> Void) {
        
        cityid[id] = coordinate
        
        if let cache = AppTheme.getTodayWeatherInfoCache(SYNC_WEATHER_INFOKEY+"\(id)") {
            let json = JSON(cache)
            self.parseWeatherData(weatherJSON: json, responseBlock: responseBlock)
        } else {
            networkWeatherRequest(coordinate, responseBlock: responseBlock)
        }
    }
    
    fileprivate func networkWeatherRequest(_ coordinate:(cityName:String, latitude: Double, longitude: Double), responseBlock: @escaping (_ id:Int,_ temp:Int, _ icon:WeatherIcon) -> Void) {
        let weatherRequest:WeatherInfoRequest = WeatherInfoRequest(latitude: coordinate.latitude, longitude: coordinate.longitude, language: nil, units: WeatherUnits.si) { (success, json, error) in
            if success {
                if let weatherJSON = json {
                    self.parseWeatherData(weatherJSON: weatherJSON, responseBlock: responseBlock)
                }else{
                    responseBlock(0, 0, .clearDay);
                }
            }else{
                responseBlock(0, 0, .clearDay)
            }
        }
        executeMEDRequest(request: weatherRequest)
    }
    
    fileprivate func parseWeatherData(weatherJSON:JSON, responseBlock: @escaping (_ id:Int,_ temp:Int, _ icon:WeatherIcon) -> Void) {
        let weatherModel:WeatherCacheModel = WeatherCacheModel(json: weatherJSON)
        var temp:Float = 0
        
        let localTimeSeconds = TimeZone.current.secondsFromGMT()
        let cityTimeInterval = Date().timeIntervalSince1970-Double(localTimeSeconds)+Double(weatherModel.offset*60*60)
        let cityDate = Date(timeIntervalSince1970: cityTimeInterval)
        var isCallBack:Bool = false
        
        for (key,value) in self.cityid {
            if weatherModel.latitude == value.1 && weatherModel.longitude == value.2 {
                self.formatter.timeZone = TimeZone(identifier: weatherModel.timezone)
                for model in weatherModel.list {
                    let hourlyDate = Date(timeIntervalSince1970: model.time)
                    let dateDetailed = hourlyDate.fromatDate(timeZone: TimeZone(identifier: weatherModel.timezone)!)
                    let hour = dateDetailed.hour != nil ? dateDetailed.hour!:-1
                    
                    if hour >= cityDate.hour {
                        isCallBack = true
                        
                        temp = model.temperature
                        
                        responseBlock(key,Int(temp) , model.icon)
                        
                        self.cityid.removeValue(forKey: key)
                        
                        do{
                            let data = try weatherJSON.rawData()
                            _ = AppTheme.KeyedArchiverName(SYNC_WEATHER_INFOKEY+"\(key)", andObject: data)
                        }catch (let error){
                            NSLog("error:\(error)")
                        }
                        
                        break
                    }
                }
                
                if isCallBack {
                    return
                }
            }else{
                networkWeatherRequest((value.0,value.1,value.2), responseBlock: responseBlock)
            }
        }
        
        responseBlock(0, 0, .clearDay);
    }
    
    func getWeatherStatusCode(icon:WeatherIcon) -> WeatherUpdateModel.WeatherStatusIcon {
        if icon == .clearDay {
            return .clearDay
        } else if icon == .clearNight {
            return .clearNight;
        } else if icon == .partlyCloudyNight {
            return .partlyCloudyNight
        } else if icon == .cloudy {
            return .cloudy
        } else if icon == .wind {
            return .windy;
        } else if icon == .snow {
            return .snow;
        } else if icon == .fog {
            return .fog;
        } else if icon == .rain {
            return .rainLight;
        } else if icon == .partlyCloudyDay {
            return .partlyCloudyDay;
        }
        return .invalidData
    }
}
