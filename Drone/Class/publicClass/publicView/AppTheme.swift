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
 

    class func SYSTEMFONTOFSIZE(mSize size:CGFloat = 25) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    class func FONT_RALEWAY_BOLD(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"SFCompactDisplay-Bold", size: size)!
    }

    class func FONT_RALEWAY_LIGHT(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"SFCompactDisplay-Light", size: size)!
    }

    class func FONT_RALEWAY_THIN(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"SFCompactDisplay-Thin", size: size)!//Uniform
    }

    class func PALETTE_BAGGROUND_COLOR() -> UIColor {
        return UIColor(red: 10/255.0, green: 255/255.0, blue: 178/255.0, alpha: 1)//Uniform
    }

    /**
    Access to resources image

    :param: imageName resource name picture

    :returns: Return to obtain images of the object
    */
    class func GET_RESOURCES_IMAGE(_ imageName:String) -> UIImage {
        let imagePath:String = Bundle.main.path(forResource: imageName, ofType: "jpg")!
        return UIImage(contentsOfFile: imagePath)!

    }

    /**
     Determine whether the iPhone4s
    :returns: If it returns true or false
    */
    class func GET_IS_iPhone4S() -> Bool {
        let isiPhone4S:Bool = (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? CGSize(width: 640, height: 960).equalTo(UIScreen.main.currentMode!.size) : false)
        return isiPhone4S
    }

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

    class func CUSTOMBAR_BACKGROUND_COLOR() ->UIColor {
        return UIColor(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
    }

    /**
    *	@brief	The archive All current data
    *
    */
    class func KeyedArchiverName(_ name:String,andObject object:Any) ->Bool{
        let pathArray:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let path:String = pathArray.first!

        let filename:String = path.appendingFormat("/%@.data", path)
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
    Calculate the height of the Label to display text

    :param: string Need to display the source text
    :param: object The control position and size the source object

    :returns: Returns the modified position and size of the source object
    */
    class func getLabelSize(_ string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        var frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading,
        var labelSize:CGSize = loclString.boundingRect(with: CGSize(width: frame.size.width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);

        var messageframe:CGRect  = frame;
        messageframe.size.height = labelSize.height;
        frame = messageframe;
        return frame
    }
    
    class func getWidthLabelSize(_ string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        let frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading
        var labelSize:CGSize = loclString.boundingRect(with: CGSize(width: 1000, height: frame.size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
        
        var messageframe:CGRect  = object;
        messageframe.size.width = labelSize.width;
        return messageframe
    }

    /**
    Phone the current language

    :returns: Language
    */
    class func getPreferredLanguage()->NSString{

        let defaults:UserDefaults = UserDefaults.standard

        let allLanguages:NSArray = defaults.object(forKey: "AppleLanguages") as! NSArray

        let preferredLang:NSString = allLanguages.object(at: 0) as! NSString
        return preferredLang;
    
    }
    /**
    Access to the local version number

    :returns: return value description
    */
    class func getLoclAppStoreVersion()->String{
        let loclString:String = (Bundle.main.infoDictionary! as NSDictionary).object(forKey: "CFBundleShortVersionString") as! String
        return loclString
    }

    /**
    Go to AppStore updating links
    */
    class func toOpenUpdateURL() {
        let url = URL(string: "https://itunes.apple.com/app/nevo-watch/id977526892?mt=8")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
        
    }


    /**
    Play the prompt
    */
    class func playSound(){
        let shake_sound_male_id:SystemSoundID  = UInt32(1005);//系统声音的id 取值范围为：1000-2000
        AudioServicesPlaySystemSound(shake_sound_male_id)
        //let path:String = NSBundle.mainBundle().pathForResource("shake_sound_male", ofType: "wav")!
        //if path.isEmpty {
            //注册声音到系统
            //AudioServicesCreateSystemSoundID((NSURL.fileURLWithPath(path) as! CFURLRef),shake_sound_male_id);
            //AudioServicesPlaySystemSound(shake_sound_male_id);
        //}
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //手机震动
    }

    /**
    Put the object into a json string

    :param: object 转换对象

    :returns: 返回转换后的json字符串
    */
    class func toJSONString(_ object:AnyObject!)->NSString{

        do{
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson=NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "") as NSString?
            strJson = strJson?.replacingOccurrences(of: " ", with: "") as NSString?
            return strJson!
        }catch{
            return ""
        }
    }

    /**
    Json string into an array

    :param: object 转换对象

    :returns: 返回转换后的数组
    */
    class func jsonToArray(_ object:String)->NSArray{
        do{
            let data:Data = object.data(using: String.Encoding.utf8)!
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let JsonToArray = array as! NSArray
            return JsonToArray
        }catch{
            return NSArray()
        }
    }

    /**
    *Hexadecimal color string into UIColor (HTML color values)
    */
    class func hexStringToColor(_ stringToConvert:String)->UIColor{
        var cString = stringToConvert.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.characters.count < 6){ return UIColor.black}
        // strip 0X if it appears
        
        if (cString.hasPrefix("0X")){ cString = cString.substring(from: cString.index(cString.startIndex, offsetBy:2))}
        if (cString.hasPrefix("#")){  cString = cString.substring(from: cString.index(cString.startIndex, offsetBy:1))}
        if (cString.characters.count != 6){ return UIColor.black}
        // Separate into r, g, b substrings

        let rString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 2))
        let gString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 4))
        let bString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 6))
        
        // Scan values
        var r:UInt32 = 0
        var g:UInt32 = 0
        var b:UInt32 = 0
        Scanner(string: rString as String).scanHexInt32(&r)
        Scanner(string: gString as String).scanHexInt32(&g)
        Scanner(string: bString as String).scanHexInt32(&b)
        return UIColor(red: CGFloat(r)/255.0, green:  CGFloat(g)/255.0, blue:  CGFloat(b)/255.0, alpha: 1)
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
    
    class func loadResourcesFile(_ fileName:String)->[NSDictionary] {
        let urlArray:[URL] = GET_RESOURCES_FILE(fileName)
        var contentArray:[NSDictionary] = []
        for url:URL in urlArray {
            let resultDictionary = NSDictionary(contentsOf: url)
            print("Loaded GameData.plist file is --> \(resultDictionary?.description)")
            if let dict = resultDictionary {
                //loading values
                dict.enumerateKeysAndObjects({ (key, obj, stop) -> Void in
                    NSLog("resultDictionary value:\(obj) key:\(key)")
                    contentArray.append(obj as! NSDictionary)
                })

            } else {
                print("WARNING: Couldn't create dictionary from File name! Default values will be used!")
                contentArray.append(["error":"No content"])
            }
        }
        return contentArray
    }

    class func getLightSleepColor () -> UIColor{
        return UIColor(red: 246/255.0, green: 211/255.0, blue: 128/255.0, alpha: 1.0)
    }

    class func getDeepSleepColor () -> UIColor{
        return UIColor(red: 252/255.0, green: 182/255.0, blue: 0/255.0, alpha: 1.0)
    }

    /**
     Get or get the resource path of the array

     :param: folderName Resource folder name

     :returns: Return path array
     */
    class func GET_RESOURCE_FILES(_ folderName:String) -> NSArray {

        let AllFilesNames:NSMutableArray = NSMutableArray()
        let appPath:NSString  = Bundle.main.resourcePath! as NSString
        let firmwaresDirectoryPath:NSString = appPath.appendingPathComponent(folderName) as NSString

        var  fileNames:[String] = []
        do {
            fileNames = try FileManager.default.contentsOfDirectory(atPath: firmwaresDirectoryPath as String)
            debugPrint("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                debugPrint("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.appendingPathComponent(fileName)
                let fileURL:URL = URL(fileURLWithPath: filePath)
                AllFilesNames.add(fileURL)
            }
            return AllFilesNames.copy() as! NSArray
        }catch{
            debugPrint("GET_RESOURCE_FILES error in opening directory path: \(firmwaresDirectoryPath)");
            return NSArray()
        }
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
