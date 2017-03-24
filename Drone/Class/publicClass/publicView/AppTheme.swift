//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox
import RegexKitLite

/**
This class holds all app-wide constants.
Colors, fonts etc...
*/
class AppTheme {
    /**
    Local notifications

    :param: string Inform the content
    */
    class func LocalNotificationBody(_ string:String, delay:Double=0) -> UILocalNotification {
        if (UIDevice.current.systemVersion as NSString).floatValue >= 8.0 {
            let categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            //UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert
            let localUns:UIUserNotificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge,UIUserNotificationType.sound,UIUserNotificationType.alert], categories: Set(arrayLiteral: categorys))
            UIApplication.shared.registerUserNotificationSettings(localUns)
        }

        
        let notification:UILocalNotification=UILocalNotification()
        notification.timeZone = TimeZone.current
        notification.fireDate = Date().addingTimeInterval(delay)
        notification.alertBody=string as String;
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.category = "invite"
        UIApplication.shared.scheduleLocalNotification(notification)
        return notification
    }

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
    
     /**
     Get the FW build-in version by parse the file name
     BLE file: imaze_20150512_v29.hex ,keyword:_v, .hex
     return: 29
     */
    class func GET_FIRMWARE_VERSION() ->Int
    {
        var buildinFirmwareVersion:Int  = 0
        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile:URL = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "hex"
            {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".hex")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinFirmwareVersion = Int(string)!
                break
            }
        }

        return buildinFirmwareVersion
    }
    /**
     Get the FW build-in version by parse the file name
     MCU file: iMaze_v12.bin ,keyword:_v, .bin
     return: 12
     */
    class func GET_SOFTWARE_VERSION() ->Int {
        var buildinSoftwareVersion:Int  = 0
        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "bin" {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".bin")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinSoftwareVersion = Int(string)!
                break
            }
        }

        return buildinSoftwareVersion
    }
    /**
     Get or get the resource path of the array

     :param: folderName Resource folder name

     :returns: Return path array
     */
    class func GET_FIRMWARE_FILES(_ folderName:String) -> NSArray {

        let AllFilesNames:NSMutableArray = NSMutableArray()
        let appPath:NSString  = Bundle.main.resourcePath! as NSString
        let firmwaresDirectoryPath:NSString = appPath.appendingPathComponent(folderName) as NSString

        var  fileNames:[String] = []
        do {
            fileNames = try FileManager.default.contentsOfDirectory(atPath: firmwaresDirectoryPath as String)
            NSLog("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                NSLog("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.appendingPathComponent(fileName)
                let fileURL:URL = URL(fileURLWithPath: filePath)
                AllFilesNames.add(fileURL)
            }
            return AllFilesNames.copy() as! NSArray
        }catch{
            NSLog("GET_FIRMWARE_FILES error in opening directory path: \(firmwaresDirectoryPath)");
            return NSArray()
        }
    }
    
    class func hexString(_ data:Data) -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }


    class func GET_RESOURCES_FILE(_ fileName:String) ->[URL]  {
        var fileURL:[URL]  = []
        let fileArray = GET_FIRMWARE_FILES(fileName)
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            //let fileName:NSString? = (selectedFile.path! as NSString).lastPathComponent
            //let fileExtension:String? = selectedFile.pathExtension
            fileURL.append(selectedFile)
        }
        return fileURL
    }

    class func isEmail(_ email:String)->Bool{
        return email.isMatched(byRegex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }

    class func isPassword(_ password:String)->Bool{
        return password.isMatched(byRegex: "^[a-zA-Z]w{5,17}$")
    }

    class func isNull(_ object:String)->Bool{
        return object.isEmpty
    }
    
    class func timerFormatValue(value:Double)->String {
        let hours:Int = Int(value).hours.value
        let minutes:Int = Int((value-Double(hours))*60).minutes.value
        if hours == 0 {
            return String(format:"%d m",minutes)
        }
        return String(format:"%d h %d m",hours,minutes)
    }
}
