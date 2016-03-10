//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox

/**
This class holds all app-wide constants.
Colors, fonts etc...
*/
class AppTheme {

    #if DEBUG
    class func DLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        NSLog("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    }
    #else
    class func DLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    }
    #endif
    /**
    This color should be used app wide on all actionable elements
    sRGB value : #ff9933
    */
    class func BASE_COLOR() -> UIColor {
        return UIColor(red: 76/255.0, green: 76/255.0, blue: 112/255.0, alpha: 1)
    }

    class func BASE_COLOR_TINT() -> UIColor {
        return UIColor(red: 160/255.0, green: 154/255.0, blue: 99/255.0, alpha: 1)
    }

    /**
    Custom colors

    :param: reds   The red channel value
    :param: greens The green channel value
    :param: blue   The blue channel value

    :returns: Custom colors
    */
    class func NEVO_CUSTOM_COLOR(Red reds:CGFloat = 186, Green greens:CGFloat = 185, Blue blue:CGFloat = 182) -> UIColor {
        return UIColor(red: reds/255.0 , green: greens/255.0, blue: blue/255.0, alpha: 1)
    }

    class func SYSTEMFONTOFSIZE(mSize size:CGFloat = 25) -> UIFont {
        return UIFont.systemFontOfSize(size)
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
    class func GET_RESOURCES_IMAGE(imageName:String) -> UIImage {
        let imagePath:String = NSBundle.mainBundle().pathForResource(imageName, ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!

    }

    /**
     Determine whether the iPhone4s
    :returns: If it returns true or false
    */
    class func GET_IS_iPhone4S() -> Bool {
        let isiPhone4S:Bool = (UIScreen.instancesRespondToSelector(Selector("currentMode")) ? CGSizeEqualToSize(CGSizeMake(640, 960), UIScreen.mainScreen().currentMode!.size) : false)
        return isiPhone4S
    }

    /**
    Local notifications

    :param: string Inform the content
    */
    class func LocalNotificationBody(string:NSString, delay:Double=0) -> UILocalNotification {
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            let categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            //UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert
            let localUns:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge,UIUserNotificationType.Sound,UIUserNotificationType.Alert], categories: Set(arrayLiteral: categorys))
            UIApplication.sharedApplication().registerUserNotificationSettings(localUns)
        }

        
        let notification:UILocalNotification=UILocalNotification()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.fireDate = NSDate().dateByAddingTimeInterval(delay)
        notification.alertBody=string as String;
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.category = "invite"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return notification
    }

    class func CUSTOMBAR_BACKGROUND_COLOR() ->UIColor {
        return UIColor(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
    }

    /**
    *	@brief	The archive All current data
    *
    */
    class func KeyedArchiverName(name:NSString,andObject object:AnyObject) ->Bool{
        var objectArray:[AnyObject] = [object.copy()]
        let senddate:NSDate = NSDate()
        let dateformatter:NSDateFormatter = NSDateFormatter()

        dateformatter.dateFormat = "YYYY/MM/dd"// HH:mm:ss
        let locationString:NSString = dateformatter.stringFromDate(senddate)
        objectArray.append(locationString)
        NSLog("locationString:%@",locationString);

        let pathArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
        let Path:NSString = (pathArray as NSArray).objectAtIndex(0) as! NSString

        let filename:NSString = Path.stringByAppendingPathComponent(name as String)
        let iswrite:Bool = NSKeyedArchiver.archiveRootObject(objectArray, toFile: filename as String)
        return iswrite
    }

    /**
    *	@brief	Load the archived data
    *
    */
    class func LoadKeyedArchiverName(name:NSString) ->AnyObject{
        let pathArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
        let Path:NSString = (pathArray as NSArray).objectAtIndex(0) as! NSString

        let filename:NSString = Path.stringByAppendingPathComponent(name as String)

        let flierManager:Bool = NSFileManager.defaultManager().fileExistsAtPath(filename as String)
        if(flierManager){
            var objectArr:AnyObject?
            objectArr = NSKeyedUnarchiver.unarchiveObjectWithFile(filename as String)!
            return objectArr!
        }
        return []
    }

    /**
    Calculate the height of the Label to display text

    :param: string Need to display the source text
    :param: object The control position and size the source object

    :returns: Returns the modified position and size of the source object
    */
    class func getLabelSize(string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        var frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading,
        var labelSize:CGSize = loclString.boundingRectWithSize(CGSizeMake(frame.size.width, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);

        var messageframe:CGRect  = frame;
        messageframe.size.height = labelSize.height;
        frame = messageframe;
        return frame
    }
    
    class func getWidthLabelSize(string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        let frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading
        var labelSize:CGSize = loclString.boundingRectWithSize(CGSizeMake(1000, frame.size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
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

        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        let allLanguages:NSArray = defaults.objectForKey("AppleLanguages") as! NSArray

        let preferredLang:NSString = allLanguages.objectAtIndex(0) as! NSString
        return preferredLang;
    
    }

    /**
    To obtain the version number on AppStore

    :param: resulVersion It contains a string version and a Double type version
    */
    class func getAppStoreVersion(resulVersion:((stringVersion:NSString?,version:Double?) -> Void)){
        let url:NSString = NSString(string: "https://itunes.apple.com/lookup?id=977526892")
        
    }

    /**
    Access to the local version number

    :returns: <#return value description#>
    */
    class func getLoclAppStoreVersion()->String{
        let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
        return loclString
    }

    /**
    Go to AppStore updating links
    */
    class func toOpenUpdateURL() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/app/nevo-watch/id977526892?mt=8")!)
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
    class func toJSONString(object:AnyObject!)->NSString{

        do{
            let data = try NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted)
            var strJson=NSString(data: data, encoding: NSUTF8StringEncoding)
            strJson = strJson?.stringByReplacingOccurrencesOfString("\n", withString: "")
            strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
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
    class func jsonToArray(object:String)->NSArray{
        do{
            let data:NSData = object.dataUsingEncoding(NSUTF8StringEncoding)!
            let array:AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            let JsonToArray = array as! NSArray
            return JsonToArray
        }catch{
            return NSArray()
        }
    }

    /**
    *Hexadecimal color string into UIColor (HTML color values)
    */
    class func hexStringToColor(stringToConvert:String)->UIColor{
        var cString:NSString = stringToConvert.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if (cString.length < 6){ return UIColor.blackColor()}
        // strip 0X if it appears
        if (cString.hasPrefix("0X")){ cString = cString.substringFromIndex(2)}
        if (cString.hasPrefix("#")){ cString = cString.substringFromIndex(1)}
        if (cString.length != 6){ return UIColor.blackColor()}
        // Separate into r, g, b substrings

        var range:NSRange = NSRange()
        range.location = 0;
        range.length = 2;
        let rString:NSString = cString.substringWithRange(range)
        range.location = 2;
        let gString:NSString = cString.substringWithRange(range)
        range.location = 4;
        let bString:NSString  = cString.substringWithRange(range)
        // Scan values
        var r:UInt32 = 0
        var g:UInt32 = 0
        var b:UInt32 = 0
        NSScanner(string: rString as String).scanHexInt(&r)
        NSScanner(string: gString as String).scanHexInt(&g)
        NSScanner(string: bString as String).scanHexInt(&b)
        return UIColor(red: CGFloat(r)/255.0, green:  CGFloat(g)/255.0, blue:  CGFloat(b)/255.0, alpha: 1)
    }

    class func navigationbar(navigation:UINavigationController) {
        if(navigation.navigationBar.respondsToSelector(Selector("setBackgroundImage:forBarMetrics:"))){
            let list:NSArray = navigation.navigationBar.subviews
            for obj in list{
                if(obj.isKindOfClass(UIImageView.classForCoder())){
                    let imageView:UIImageView = obj as! UIImageView
                    imageView.hidden = true
                }
            }
            let imageView:UIImageView = UIImageView(frame: CGRectMake(0, -20, 420, 64))
             imageView.image = UIImage(named: "navigationBar")
            imageView.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 227.0, Green: 227.0, Blue: 227.0)
            navigation.navigationBar.addSubview(imageView)
            navigation.navigationBar.sendSubviewToBack(imageView)
        }
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
            let selectedFile:NSURL = tmpfile as! NSURL
            let fileName:NSString? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "hex"
            {
                let ran:NSRange = fileName!.rangeOfString("_v")
                let ran2:NSRange = fileName!.rangeOfString(".hex")
                let string:String = fileName!.substringWithRange(NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
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
            let selectedFile = tmpfile as! NSURL
            let fileName:NSString? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "bin" {
                let ran:NSRange = fileName!.rangeOfString("_v")
                let ran2:NSRange = fileName!.rangeOfString(".bin")
                let string:String = fileName!.substringWithRange(NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
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
    class func GET_FIRMWARE_FILES(folderName:String) -> NSArray {

        let AllFilesNames:NSMutableArray = NSMutableArray()
        let appPath:NSString  = NSBundle.mainBundle().resourcePath!
        let firmwaresDirectoryPath:NSString = appPath.stringByAppendingPathComponent(folderName)

        var  fileNames:[String] = []
        do {
            fileNames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(firmwaresDirectoryPath as String)
            AppTheme.DLog("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                AppTheme.DLog("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.stringByAppendingPathComponent(fileName)
                let fileURL:NSURL = NSURL.fileURLWithPath(filePath)
                AllFilesNames.addObject(fileURL)
            }
            return AllFilesNames.copy() as! NSArray
        }catch{
            AppTheme.DLog("error in opening directory path: \(firmwaresDirectoryPath)");
            return NSArray()
        }
    }

    class func hexToBytes(hexString:NSString)->NSData {
        let data:NSMutableData = NSMutableData()
        for(var index:Int=0;index<hexString.length;index+=2) {
            let range:NSRange =  NSMakeRange(index, index+2>hexString.length ? 1:2 )
            var hexStr:NSString = hexString.substringWithRange(range)
            hexStr = index+2>hexString.length ? hexStr:"0" + (hexStr as String)
            let scanner:NSScanner = NSScanner(string: "\(hexStr)")
            var intValue:UInt32 = 0
            scanner.scanHexInt(&intValue)
            data.appendBytes(&intValue, length: 1)
        }
        return data;
    }

    class func hexString(data:NSData) -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }


    class func GET_RESOURCES_FILE(fileName:String) ->[NSURL]  {
        var fileURL:[NSURL]  = []
        let fileArray = GET_FIRMWARE_FILES(fileName)
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! NSURL
            //let fileName:NSString? = (selectedFile.path! as NSString).lastPathComponent
            //let fileExtension:String? = selectedFile.pathExtension
            fileURL.append(selectedFile)
        }
        return fileURL
    }
    
    class func loadResourcesFile(fileName:String)->[NSDictionary] {
        let urlArray:[NSURL] = GET_RESOURCES_FILE(fileName)
        var contentArray:[NSDictionary] = []
        for url:NSURL in urlArray {
            let resultDictionary = NSDictionary(contentsOfURL: url)
            print("Loaded GameData.plist file is --> \(resultDictionary?.description)")
            if let dict = resultDictionary {
                //loading values
                dict.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
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
}