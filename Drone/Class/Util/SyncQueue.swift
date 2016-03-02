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
    private let MAX_LOCK_TIME = 5
    
    /** The stored commands, that are waiting to be executed. */
    private var mQueue:[ (Void) -> (Void) ]=[]
    
    /** If this is true, then we are currently waiting for something before we can continue*/
    private var mLock:Bool = false
    
    /** This Runnable, is the Timeout task. It's timer is set to 0 every time we put a new lock */
    private var mTimeoutTimer:NSTimer?
    
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
    private override init() {
        
    }
    
    /**
    * Post a closure or store it (if we are already locked)
    *
    * @param r the runnable
    */
    func post(task:  (Void) -> (Void) ){
    
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
            post(mQueue.removeAtIndex(0))
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
    private func lock(){
        AppTheme.DLog("SyncController : Waiting for a response...")
        mLock = true
    
        //Here we reset the Timeout timer
        mTimeoutTimer?.invalidate()
        
        mTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Double(MAX_LOCK_TIME), target: self, selector:Selector("next"), userInfo: nil, repeats: false)
    
    }
    
    /**
    * Unlocks the handler.
    */
    private func unlock(){
        AppTheme.DLog("SyncController : Response received or timeout")
        mLock = false
    
        //Here we reset the Timeout timer
        mTimeoutTimer?.invalidate()
    }
    
}