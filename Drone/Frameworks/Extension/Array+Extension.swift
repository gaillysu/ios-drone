//
//  Array+Extension.swift
//  Nevo
//
//  Created by Cloud on 2017/5/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

extension Array where Iterator.Element == Int {
    
    func toJSONString()-> String {
        do{
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson = String(data: data, encoding: String.Encoding.utf8)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "")
            strJson = strJson?.replacingOccurrences(of: " ", with: "")
            if let returnString = strJson {
                return returnString
            }
            return "[]"
        }catch{
            return "[]"
        }
    }
}

extension Array where Iterator.Element == [Int] {
    
    func toJSONString()-> String {
        do{
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson = String(data: data, encoding: String.Encoding.utf8)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "")
            strJson = strJson?.replacingOccurrences(of: " ", with: "")
            if let returnString = strJson {
                return returnString
            }
            return "[]"
        }catch{
            return "[]"
        }
    }
}

extension Array where Iterator.Element == Double {
    
    func toJSONString()-> String {
        do{
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson = String(data: data, encoding: String.Encoding.utf8)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "")
            strJson = strJson?.replacingOccurrences(of: " ", with: "")
            if let returnString = strJson {
                return returnString
            }
            return "[]"
        }catch{
            return "[]"
        }
    }
}

extension Array where Iterator.Element == [Double] {
    
    func toJSONString()-> String {
        do{
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson = String(data: data, encoding: String.Encoding.utf8)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "")
            strJson = strJson?.replacingOccurrences(of: " ", with: "")
            if let returnString = strJson {
                return returnString
            }
            return "[]"
        }catch{
            return "[]"
        }
    }
}
