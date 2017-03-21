//
//  SandboxManager.swift
//  Drone
//
//  Created by Cloud on 2016/11/21.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import XCGLogger

class SandboxManager: NSObject {
    private let projectName:String = Bundle.main.infoDictionary![kCFBundleExecutableKey as String] as! String    //获取项目名称
    override init() {
        super.init()
    }
    
    //获取沙盒路径
    func homePath() -> String {
        return NSHomeDirectory();
    }
    
    //获取document路径
    func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0];
    }
    
    //获取library路径
    func libraryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0];
    }
    
    //获取tmp文件路径
    func tmpPath() -> String {
        return NSTemporaryDirectory();
    }
    
    //获取caches文件路径
    func cachesPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0];
    }
    
    func copyDictFileToSandBox(folderName:String,fileName:String)->Bool {
        let fileResources = AppTheme.GET_FIRMWARE_FILES(folderName)
        if fileResources.count > 0 {
            let documentPath:String = self.documentPath().appending("/\(projectName)/")
            let url:URL = fileResources[0] as! URL
            let localDict:NSDictionary = NSDictionary(contentsOf: url)!
            let fileManager:FileManager  = FileManager.default;
            if !fileManager.isExecutableFile(atPath: documentPath) {
                try! fileManager.createDirectory(atPath: documentPath, withIntermediateDirectories: true, attributes: nil)
                do {
                    try fileManager.copyItem(atPath: url.path, toPath: documentPath+fileName)
                    return true;
                } catch let error as NSError {
                    NSLog("copyItem error:%@", error)
                    return false
                }
            }else{
                let sandBoxDict:NSMutableDictionary = NSMutableDictionary()
                for (key ,value) in (self.readDataWithName(type: "",fileName: fileName) as! NSDictionary) {
                    sandBoxDict.setValue(value, forKey: key as! String)
                }
            
                let sandBoxVersion:String = sandBoxDict.object(forKey: "Version") as! String
                let localVersion:String = localDict.object(forKey: "Version") as! String
                
                if sandBoxVersion.toDouble() < localVersion.toDouble() {
                    return sandBoxDict.write(toFile: documentPath+"/"+fileName, atomically: true)
                }else{
                    XCGLogger.default.debug("本地文件是最新的,不需要写入沙盒")
                    return false;
                }
            }
        }else{
            return false;
        }
    }
    
    //读取文件
    func readDataWithName(type:NSString,fileName:String) -> Any {
        let path = documentPath().appending("/\(projectName)/\(fileName)")
        if type.isEqual(to: "String") {
            return try! String(contentsOfFile: path, encoding: .utf8)
        }else if type.isEqual(to: "Data") {
            return try! Data(contentsOf: URL(fileURLWithPath: path))
        }else if type.isEqual(to: "Array") {
            return NSArray(contentsOfFile: path)!
        }else if type.isEqual(to: "Dictionary") {
            return NSDictionary.init(contentsOfFile: path)!
        }
        return NSDictionary.init(contentsOfFile: path)!
        
    }
    
    func saveDataWithName(saveData:Any,fileName:String)->Bool {
        let path = documentPath().appending("/\(projectName)/\(fileName).plist")
        let localDict:NSDictionary = saveData as! NSDictionary
        return localDict.write(toFile: path, atomically: true)
    }
}
