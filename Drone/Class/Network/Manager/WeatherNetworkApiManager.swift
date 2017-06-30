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
    
    fileprivate static let baseURL = "http://api.openweathermap.org/"
    static let manager:WeatherNetworkApiManager = WeatherNetworkApiManager()
    
    fileprivate var cityid:[String:Int] = [:]
    
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
            if(json["list"].arrayValue.count == 0){
                return (false,json, nil)
            }else{
                return (true, json, nil)
            }
        case .failure(let error):
            return (false,nil, error)
        }
    }
    
    func getWeatherInfo(regionName:String, id:Int, responseBlock: @escaping (_ id:Int,_ temp:Int, _ code:Int, _ statusText:String?) -> Void) {
        
        cityid[regionName] = id
        let cityArray:[City] = DataBaseManager.manager.getCitySelected()
        
        if let cache = AppTheme.LoadKeyedArchiverName(SYNC_WEATHER_INFOKEY+regionName) {
            let weatherModel:WeatherCacheModel = cache as! WeatherCacheModel
            let cacheDate:TimeInterval = weatherModel.syncDate.toDouble()
            let cityName:String = weatherModel.city.name
            if Date(timeIntervalSince1970: cacheDate) == Date.today()&&cityName.hasPrefix(regionName) {
                var isCallBack:Bool = false
                
                let city = cityArray.filter({$0.name.hasPrefix(cityName)}).last
                let localTimeSeconds = TimeZone.current.secondsFromGMT()
                
                var cityTime = 0.0
                if let offset = city?.timezone?.gmtTimeOffset {
                    cityTime = Date().timeIntervalSince1970-Double(localTimeSeconds)+Double(offset*60);
                }
                
                let cityDate = Date(timeIntervalSince1970: cityTime==0 ? (Date().timeIntervalSince1970-Double(localTimeSeconds)):cityTime)
                for listModel in weatherModel.list {
                    if let offset = city?.timezone?.gmtTimeOffset {
                        self.formatter.timeZone = TimeZone(secondsFromGMT: Int(offset*60))
                    }
                    
                    let dateString = self.formatter.string(from: Date(timeIntervalSince1970: listModel.dt.toDouble()))
                    print("cityDate:\(cityDate.stringFromFormat("yyyy-MM-dd HH:mm:ss"))")
                    if let hourDate = self.formatter.date(from: dateString) {
                        if hourDate.hour > cityDate.hour {
                            isCallBack = true
                            let temp:Int = Int(listModel.temp.toFloat())
                            let code:Int = listModel.code.toInt()
                            let text:String = listModel.stateText
                            responseBlock(id,temp , code, text)
                            break
                        }
                    }
                }
                if isCallBack {
                    self.cityid.removeValue(forKey: regionName)
                    return
                }
            }
        }
        
        let weatherRequest:WeatherInfoRequest = WeatherInfoRequest(selectText: regionName) { (success, json, error) in
            if success {
                if let weatherJSON = json {
                    let weatherModel:WeatherCacheModel = WeatherCacheModel()
                    weatherModel.cod = weatherJSON["cod"].stringValue
                    weatherModel.message = weatherJSON["message"].stringValue
                    weatherModel.cnt = weatherJSON["cnt"].stringValue
                    weatherModel.syncDate = String(format: "%f", Date.today().timeIntervalSince1970)
                    
                    let listModel:[EveryHourWeatherModel] = self.getEveryHourWeatherModel(json: weatherJSON)
                    weatherModel.list = listModel
                    
                    let cityModel:WeatherCityModel = self.getWeatherCityModel(json: weatherJSON)
                    let cityName:String = cityModel.name
                    weatherModel.city = cityModel
                    
                    let name:String = cityName
                    var temp:Float = 0
                    var code:Int = 0
                    var text:String = listModel.first!.stateText
                    let city = cityArray.filter({$0.name.hasPrefix(cityName)}).last
                    let localTimeSeconds = TimeZone.current.secondsFromGMT()
                    
                    var cityTime = 0.0
                    if let offset = city?.timezone?.gmtTimeOffset {
                        cityTime = Date().timeIntervalSince1970-Double(localTimeSeconds)+Double(offset*60);
                    }
                    
                    let cityDate = Date(timeIntervalSince1970: cityTime==0 ? (Date().timeIntervalSince1970-Double(localTimeSeconds)):cityTime)
                    for model in listModel{
                        if let offset = city?.timezone?.gmtTimeOffset {
                            self.formatter.timeZone = TimeZone(secondsFromGMT: Int(offset*60))
                        }
                        let dateString = self.formatter.string(from: Date(timeIntervalSince1970: model.dt.toDouble()))
                        print("cityDate:\(cityDate.stringFromFormat("yyyy-MM-dd HH:mm:ss"))")
                        if let hourDate = self.formatter.date(from: dateString) {
                            if hourDate.hour > cityDate.hour {
                                temp = model.temp.toFloat()
                                code = model.code.toInt()
                                text = model.stateText;
                                break
                            }
                        }
                    }
                    
                    self.tempValue = Int(temp)
                    self.weatherStatusText = text
                    
                    for (key,value) in self.cityid {
                        if key.hasPrefix(name) {
                            responseBlock(value,self.tempValue , code, self.weatherStatusText)
                            self.cityid.removeValue(forKey: key)
                            break;
                        }
                    }
                    _ = AppTheme.KeyedArchiverName(SYNC_WEATHER_INFOKEY+cityModel.id, andObject: weatherModel)
                }else{
                    responseBlock(0,0, 0, nil);
                }
            }else{
                responseBlock(0, 0, 0, nil)
            }
        }
        executeMEDRequest(request: weatherRequest)
    }
    
    fileprivate func getWeatherCityModel(json:JSON) -> WeatherCityModel {
        let city:[String:JSON] = json["city"].dictionaryValue
        let cityModel:WeatherCityModel = WeatherCityModel()
        let cityName:String = city["name"]!.stringValue
        cityModel.id = city["id"]!.stringValue
        cityModel.name = cityName
        cityModel.lat = city["coord"]!.dictionaryValue["lat"]!.stringValue
        cityModel.lon = city["coord"]!.dictionaryValue["lon"]!.stringValue
        cityModel.country = city["country"]!.stringValue
        return cityModel
    }
    
    fileprivate func getEveryHourWeatherModel(json:JSON) -> [EveryHourWeatherModel] {
        let listArray:[JSON] = json["list"].arrayValue
        var listModel:[EveryHourWeatherModel] = []
        for list in listArray {
            let model:EveryHourWeatherModel = EveryHourWeatherModel()
            model.dt = list["dt"].stringValue
            model.temp = list["main"].dictionaryValue["temp"]!.stringValue
            let weather:[String:JSON] = list["weather"].arrayValue.first!.dictionaryValue
            model.code = weather["id"]!.stringValue
            model.stateText = weather["main"]!.stringValue
            model.dt_txt = list["dt_txt"].stringValue
            listModel.append(model)
        }
        return listModel
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
