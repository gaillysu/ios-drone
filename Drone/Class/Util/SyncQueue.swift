//
//  SyncQueue.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/3/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/**
We shouldn't send two packets before receiving hte answer from the first one.
So this class is here to be sure of that.
It will receive different Closures and will run them when appropriate
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class SyncQueue : NSObject {
    /** The max lock time before timeout. */
    fileprivate let MAX_LOCK_TIME = 5
    
    /** The stored commands, that are waiting to be executed. */
    fileprivate var mQueue:[ (Void) -> (Void) ]=[]
    
    /** If this is true, then we are currently waiting for something before we can continue*/
    fileprivate var mLock:Bool = false
    
    /** This Runnable, is the Timeout task. It's timer is set to 0 every time we put a new lock */
    fileprivate var mTimeoutTimer:Timer?
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : SyncQueue {
        struct Singleton {
            static let instance = SyncQueue()
        }
        return Singleton.instance
    }
    //add for OTA use
    class var sharedInstance_ota : SyncQueue {
        struct Singleton {
            static let instance = SyncQueue()
        }
        return Singleton.instance
    }

    
    /**
    No initialisation outside of this class, this is a singleton
    */
    fileprivate override init() {
        
    }
    
    /**
    * Post a closure or store it (if we are already locked)
    *
    * @param r the runnable
    */
    func post(_ task:  @escaping (Void) -> (Void) ){
    
        //Let's check if we are locked (e.g. have a pending request
        if(mLock == true){

            //If we are locked, we'll store this runnable for later
			mQueue.append(task)

        } else {
            
            //If we are not locked, we put the lock then run a task
            lock()
            
            task()
    
        }
    }
    
    /**
    * This function will release the lock and allow our handler to handle the next task (if any)
    */
    func next(){
        unlock()
    
        if(mQueue.count>=1){
            post(mQueue.remove(at: 0))
        }
    }
    
    /**
    * Deletes all pending commands without executing them
    */
    func clear(){
        unlock()
    
        mQueue = []
    }
    
    /**
    * Locks the handler
    */
    fileprivate func lock(){
        NSLog("SyncController : Waiting for a response...")
        mLock = true
    
        //Here we reset the Timeout timer
        mTimeoutTimer?.invalidate()
        
        mTimeoutTimer = Timer.scheduledTimer(timeInterval: Double(MAX_LOCK_TIME), target: self, selector:#selector(next), userInfo: nil, repeats: false)
    
    }
    
    /**
    * Unlocks the handler.
    */
    fileprivate func unlock(){
        NSLog("SyncController : Response received or timeout")
        mLock = false
    
        //Here we reset the Timeout timer
        mTimeoutTimer?.invalidate()
    }
    
}
