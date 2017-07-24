//
//  AppTheme.swift
//  Nevo
//
//  Created by Karl on Now.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox

enum ActionType {
    case get
    case set
}

var countryCode:String?{
    let currentLocale:Locale = Locale.current
    let countryCode = currentLocale.regionCode
    return countryCode
}

var localLanguage:String? {
    let currentLocale:Locale = Locale.current
    let language = currentLocale.languageCode
    return language
}

class AppTheme {

    /**
    *	@brief	The archive All current data
    *
    */
    class func KeyedArchiverName(_ name:String,andObject object:Any) ->Bool{
        let pathArray:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let path:String = pathArray.first!

        let filename:String = path.appendingFormat("/%@.data", name)
        let result = NSKeyedArchiver.archiveRootObject(object, toFile: filename)
        return result
    }

    /**
    *	@brief	Load the archived data
    */
    class func LoadKeyedArchiverName(_ name:String) ->Any?{
        let pathArray:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let path:String = pathArray.first!
        let filename:String = path.appendingFormat("/%@.data",name)

        let flierManager:Bool = FileManager.default.fileExists(atPath: filename as String)
        if(flierManager){
            return NSKeyedUnarchiver.unarchiveObject(withFile: filename as String)
        }
        return nil
    }
    
    class func getTodayWeatherInfoCache(_ name:String) ->Any? {
        let pathArray:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let path:String = pathArray.first!
        let filename:String = path.appendingFormat("/%@.data",name)
        
        let flierManager:Bool = FileManager.default.fileExists(atPath: filename as String)
        if(flierManager){
            do {
                let object = try FileManager.default.attributesOfItem(atPath: filename)
                if let date = object[FileAttributeKey.creationDate] {
                    let modificationDate = (date as? Date) == nil ?Date():(date as? Date)
                    let todayDate = Date().stringFromFormat("yyyyMMddHH").toInt()
                    let cacheDate = modificationDate!.stringFromFormat("yyyyMMddHH").toInt()
                    if todayDate>cacheDate {
                        try FileManager.default.removeItem(atPath: filename)
                        return nil
                    }
                }
            } catch let error {
                NSLog("error:\(error)")
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(withFile: filename as String)
        }
        return nil
    }
    
    /**
     Get or get the resource path of the array

     :param: folderName Resource folder name

     :returns: Return path array
     */
    class func GET_FIRMWARE_FILES(_ folderName:String) -> [URL] {
        var fileUrls:[URL] = []
        let appPath:NSString  = Bundle.main.resourcePath! as NSString
        let firmwaresDirectoryPath:NSString = appPath.appendingPathComponent(folderName) as NSString
        print("\(firmwaresDirectoryPath)")
        var  fileNames:[String] = []
        do {
            fileNames = try FileManager.default.contentsOfDirectory(atPath: firmwaresDirectoryPath as String)
            NSLog("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                NSLog("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.appendingPathComponent(fileName)
                let fileURL:URL = URL(fileURLWithPath: filePath)
                fileUrls.append(fileURL)
            }
        }catch{
            NSLog("GET_FIRMWARE_FILES error in opening directory path: \(firmwaresDirectoryPath)");
            return []
        }
        return fileUrls
    }
    
    class func hexString(_ data:Data) -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
 
    class func isEmail(_ email:String)->Bool{
        let currObject:String = email
        let predicateStr:String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }

    class func isPassword(_ password:String)->Bool{
        let currObject:String = password
        let predicateStr:String = "^[a-zA-Z]w{5,17}$"
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }

    class func isNull(_ object:String)->Bool{
        return object.isEmpty
    }
    
    class func firmwareVersionFrom(path:URL) -> Double {
        let str = path.absoluteString
        let begin = str.range(of: "dayton_SW_")!.lowerBound
        let range = begin..<str.endIndex
        
        let fileName = str.substring(with: range)
        
        let start = fileName.index(fileName.startIndex, offsetBy: 11)
        let end = fileName.index(fileName.endIndex, offsetBy: -4)
        var versionName = fileName.substring(with: start..<end)
        versionName.insert(".", at: versionName.range(of: "0")!.upperBound)
        guard let version = Double(versionName) else{
            fatalError("Could not parse version for some reason.")
        }
        return version
    }
    
    class func realmISFirstCopy(findKey:ActionType)->Bool {
        if findKey == .get {
            if let value = UserDefaults.standard.object(forKey: "ISFirstCopy") {
                let index:Bool = value as! Bool
                return index
            }else{
                return false
            }
        }
        
        if findKey == .set {
            UserDefaults.standard.set(true, forKey: "ISFirstCopy")
            return true
        }
        return false
    }
}
