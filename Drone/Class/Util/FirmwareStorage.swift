
//
//  FirmwareStorage.swift
//  Drone
//
//  Created by Karl-John Chow on 24/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

class FirmwareStorage {
    
    let filemanager = FileManager.default
    
    func save(version:Double, firmware:Data) -> String{
        do {
            let path = generateUrlFor(version: version)
            if !exist(url: path.absolute){
                try FileManager.default.createDirectory(atPath: path.absolute.deletingLastPathComponent().relativePath, withIntermediateDirectories: true, attributes: nil)
            }
            try firmware.write(to: path.absolute)
            return path.short
        } catch let error as NSError {
            print("Error Firmware: \(error.debugDescription)")
        }
        return ""
        
    }
    
    func getFirmware(path:String) -> URL{
        return URL(fileURLWithPath: localDocumentUrl(), isDirectory: false).appendingPathComponent("firmwares/\(path)")
    }
    
    private func localDocumentUrl() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func generateUrlFor(version:Double) -> (absolute:URL,short:String) {
        let filePathFromDocument = "firmwares/\(version).zip"
        return (URL(fileURLWithPath: localDocumentUrl(), isDirectory: true).appendingPathComponent(filePathFromDocument) ,filePathFromDocument)
    }
    
    private func exist(url:URL) -> Bool{
        // Gotta find out when this works. Maybe with RelativePath?
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
    func firmwareExist(version:Double) -> Bool{
        return exist(url: generateUrlFor(version: version).absolute)
    }
    
    func delete(url:URL) {
        do {
            if exist(url: url) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Error Deleting file")
        }
    }
}

