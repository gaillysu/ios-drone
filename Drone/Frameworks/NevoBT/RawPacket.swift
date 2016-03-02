//
//  RawPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
Implementation of the NevoBT Protocol
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol RawPacket {
    
    /**
    The service and Char that sent packet
    */
    func getSourceProfile() -> Profile
    
    /**
    The raw packet data
    */
    func getRawData() -> NSData
    
    /**
    return the packet's Header(protocol command)
    such as 00XX.....,
    Header value: XX
    header offset: 1
    */
    func getHeader() -> UInt8
    
    /**
    return true or false , true , end of packets
    */
    func isLastPacket() ->Bool
    
}

class RawPacketImpl : RawPacket {
    private var mData:NSData
    private var mProfile:Profile
    
    
    init( data:NSData, profile:Profile ) {
        mData=data
        mProfile=profile
    }
    
    func getSourceProfile() -> Profile {
        return mProfile
    }
    
    func getRawData() -> NSData {
        return mData
    }
    
    func getHeader() -> UInt8
    {
        return NSData2Bytes(mData)[1]
    }
    func isLastPacket() ->Bool
    {
        return (NSData2Bytes(mData)[0] == 0xFF)
    }
}