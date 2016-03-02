//
//  ConnectionManager.swift
//  Nevo
//
//  Created by ideas on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject {
    private var mConnectedLocalMsg:[UILocalNotification] = []
    private var mDisconnectedLocalMsg:[UILocalNotification] = []
    private var mIsSendLocalMsg:Bool = false
    private let mIsSendLocalMsgKey:String = "IsSendLocalMsg"
    
    struct Const {
        static var connectedTime:Int?
        static var disconnectTime:Int?
        static let maxReconnectTime:Double = 20
        enum connectionStatus:String {
            case connected = "Connected"
            case disconnected = "Disconnect"
        }
        enum connectionLocalMsgType:String {
            case connected = "Connected"
            case disconnected = "Disconnect"
            case all = "All"
        }
        static let isShowBeforeMsg = false
    }
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : ConnectionManager {
        struct Singleton {
            static let instance = ConnectionManager()
        }
        return Singleton.instance
    }
    
    /**
    No initialisation outside of this class, this is a singleton
    */
    private override init() {
        super.init()
        mIsSendLocalMsg = getIsSendLocalMsg()
    }
    
    /**
    get mIsSendLocalMsg
    
    :returns: <#return value description#>
    */
    func getIsSendLocalMsg() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var val:Bool = false
        if let isOpen: AnyObject = userDefaults.objectForKey(mIsSendLocalMsgKey) {
            val = isOpen as! Bool
        }
        return val
    }
    
    /**
    set mIsSendLocalMsg
    
    :param: val bool
    */
    func setIsSendLocalMsg(val:Bool){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(val,forKey:mIsSendLocalMsgKey)
        userDefaults.synchronize()
    }
    
    /**
    set the connected time
    
    :param: timeInter timeIntervalSince1970
    */
    func setConnectedTime(timeInter:Int) {
        //remove all connected msg before
        removeAllConnectionMsgBefore()
        let nowTime = Int(NSDate().timeIntervalSince1970)
        ConnectionManager.Const.connectedTime = timeInter
        
        if let preConnectedTime = ConnectionManager.Const.connectedTime {
            //if disconnecttime and connectedtime not more than 20 seconds, not show the connected msg
            if let preDisconnectTime = ConnectionManager.Const.disconnectTime {
                if nowTime - preDisconnectTime > Int(ConnectionManager.Const.maxReconnectTime) {
                    AppTheme.DLog("show the connected msg")
                    let connectedMsg = AppTheme.LocalNotificationBody(NSLocalizedString(ConnectionManager.Const.connectionStatus.connected.rawValue,comment: ""))
                    mConnectedLocalMsg.append(connectedMsg)
                }
            }
        }
        
        
        //if disconnecttime and connectedtime not more than 20 seconds, cancel the disconnect msg
        if let preDisconnectedTime = ConnectionManager.Const.disconnectTime {
            AppTheme.DLog("checkConnectSendNotification connected time \(nowTime) offset: \(nowTime - preDisconnectedTime)")
            if nowTime - preDisconnectedTime < Int(ConnectionManager.Const.maxReconnectTime) {
                var arrayIndex = 0
                for disMsg in mDisconnectedLocalMsg {
                    let disMsgTimer:NSDate = disMsg.fireDate!
                    AppTheme.DLog("cancel disconnect msg \(disMsgTimer.timeIntervalSince1970)")
                    //if the msg is not show , cancel it
                    if NSDate().timeIntervalSince1970 - disMsgTimer.timeIntervalSince1970 < 0 {
                        UIApplication.sharedApplication().cancelLocalNotification(disMsg)
                        mDisconnectedLocalMsg.removeAtIndex(arrayIndex)
                    }
                    arrayIndex++
                }
            }
            
        }
        
    }
    
    /**
    remove all connection msg before, so we only see one msg
    */
    func removeAllConnectionMsgBefore(type:Const.connectionLocalMsgType = Const.connectionLocalMsgType.all) {
        if ConnectionManager.Const.isShowBeforeMsg == false {
            if type == Const.connectionLocalMsgType.all || type == Const.connectionLocalMsgType.connected {
                for cmsgTimer in mConnectedLocalMsg {
                    UIApplication.sharedApplication().cancelLocalNotification(cmsgTimer)
                }
                mConnectedLocalMsg = []
            }
            if type == Const.connectionLocalMsgType.all || type == Const.connectionLocalMsgType.disconnected {
                for dmsgTimer in mDisconnectedLocalMsg {
                    UIApplication.sharedApplication().cancelLocalNotification(dmsgTimer)
                }
                mDisconnectedLocalMsg = []
            }
            
        }
    }
    
    /**
    set the disconnect time
    
    :param: timeInter timeIntervalSince1970
    */
    func setDisconnectTime(timeInter:Int) {
        removeAllConnectionMsgBefore(ConnectionManager.Const.connectionLocalMsgType.disconnected)
        ConnectionManager.Const.disconnectTime = timeInter
        if let connectedTime = ConnectionManager.Const.connectedTime {
            AppTheme.DLog("checkConnectSendNotification disconnected time \(timeInter) offset: \(timeInter - connectedTime)")
        }
        let disconnectMsg = AppTheme.LocalNotificationBody(NSLocalizedString(ConnectionManager.Const.connectionStatus.disconnected.rawValue,comment: ""), delay: ConnectionManager.Const.maxReconnectTime)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("aWindowBecameMain"), name: UILocalNotificationDefaultSoundName, object: nil)
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aWindowBecameMain:) name:NSWindowDidBecomeMainNotification object:nil];
        //UIApplicationLaunchOptionsLocalNotificationKey
        mDisconnectedLocalMsg.append(disconnectMsg)
    }

    
    /**
    check the connection and send local notification if necessary
    
    :param: type ConnectionManager.Const.connectionStatus
    */
    func checkConnectSendNotification(type:ConnectionManager.Const.connectionStatus){
        //if not open the send local notification , not go on
        if getIsSendLocalMsg() == false {
            AppTheme.DLog("checkConnectSendNotification local notification not open")
            return
        }
        let nowTime = Int(NSDate().timeIntervalSince1970)
        switch type {
        case .connected:
            AppTheme.DLog("checkConnectSendNotification connected time \(nowTime)")
            setConnectedTime(nowTime)
        case .disconnected:
            AppTheme.DLog("checkConnectSendNotification disconnected time \(nowTime)")
            setDisconnectTime(nowTime)
        default:
            AppTheme.DLog("checkConnectSendNotification default")
        }
    }
    
    
}
