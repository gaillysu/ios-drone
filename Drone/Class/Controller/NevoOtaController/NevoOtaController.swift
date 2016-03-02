//
//  NevoOtaController.swift
//  Nevo
//
//  Created by supernova on 15/2/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

/**

this file is main OTA controller
usage: 
var mNevoOtaController : NevoOtaController?
mNevoOtaController = NevoOtaController(controller: self)


*/

import Foundation


class NevoOtaController : NSObject,ConnectionControllerDelegate {
    var mDelegate : NevoOtaControllerDelegate?
    let mConnectionController : ConnectionController = AppDelegate.getAppDelegate().getMconnectionController()
    
    var dfuFirmwareType : DfuFirmwareTypes = DfuFirmwareTypes.APPLICATION
    private var mPacketsbuffer:[NSData]=[]
    private var binFileSize:Int = 0
    private var uploadTimeInSeconds:Int = 0
    private var firmwareFile :NSURL?
    private var dfuResponse:DFUResponse = DFUResponse(responseCode: 0,requestedCode: 0,responseStatus: 0)
    
    private var binFileData:NSData?
    private var numberOfPackets:Int = 0
    private var bytesInLastPacket:Int = 0
    private var writingPacketNumber :Int = 0
    
    /** check the OTA is doing or stop */
    private var mTimeoutTimer:NSTimer?
    private let MAX_TIME = 30
    private var lastprogress = 0.0
    //added for MCU OTA
    
    /**
    MCU page struct: total 5 packets, as below:
    
    app --> BLE
    0071................... header
    0171................... 18 bytes from firmware
    0271................... 18 bytes from firmware
    0371................... 18 bytes from firmware
    FF71...........00000000 10 bytes from firmware
    
    BLE --> app
    0071
    FF71
    */
    let DFUCONTROLLER_MAX_PACKET_SIZE = 18
    let DFUCONTROLLER_PAGE_SIZE = 64
    //one page has 5 packets
    let notificationPacketInterval = 5
    private var state:DFUControllerState = DFUControllerState.INIT
    private var firmwareDataBytesSent:Int = 0
    private var progress = 0.0
    private var curpage:Int = 0
    private var totalpage:Int = 0
    private  var checksum:Int = 0
    //end added
    
    init(controller : NevoOtaViewController) {
        super.init()
        mDelegate = controller
        mConnectionController.setDelegate(self)
        mConnectionController.connect()

    }

    private func openFile(fileURL:NSURL){
        let selectedFileName:NSString  = fileURL.lastPathComponent!
        let filetype:NSString = selectedFileName.substringFromIndex(selectedFileName.length - 3)
        
        AppTheme.DLog("selected file extension is \(filetype)")
        
        if filetype == "hex"{
            let hexFileData :NSData = NSData(contentsOfURL: fileURL)!;
            if (hexFileData.length > 0) {
                convertHexFileToBin(hexFileData)
            }else{
                AppTheme.DLog("Error: file is empty!");
                let errorMessage = "Error on openning file\n Message: file is empty or not exist";
                mDelegate?.onError(errorMessage)
            }
        }else{
            MCU_openfirmware(fileURL)
        }
    }
    
    private func convertHexFileToBin(hexFileData:NSData){
        binFileData = IntelHex2BinConverter.convert(hexFileData)
        AppTheme.DLog("HexFileSize: \(hexFileData.length) and BinFileSize: \(binFileData?.length)")
        numberOfPackets =  (binFileData?.length)! / enumPacketOption.PACKET_SIZE.rawValue
        bytesInLastPacket = ((binFileData?.length)! % enumPacketOption.PACKET_SIZE.rawValue);
        if (bytesInLastPacket == 0) {
            bytesInLastPacket = enumPacketOption.PACKET_SIZE.rawValue;
        }else{
            numberOfPackets = numberOfPackets + 1
        }
        AppTheme.DLog("Number of Packets \(numberOfPackets) Bytes in last Packet \(bytesInLastPacket)")
        writingPacketNumber = 0

        binFileSize = (binFileData?.length)!
        dfuFirmwareType = DfuFirmwareTypes.APPLICATION
    }
    
    private func writeNextPacket(){
        var percentage :Int = 0;
        for (var index:Int = 0; index<Int(enumPacketOption.PACKETS_NOTIFICATION_INTERVAL.rawValue); index++) {
            if (self.writingPacketNumber > self.numberOfPackets-2) {
                AppTheme.DLog("writing last packet");
                let dataRange : NSRange = NSMakeRange(self.writingPacketNumber*enumPacketOption.PACKET_SIZE.rawValue, self.bytesInLastPacket);
                let nextPacketData : NSData = (binFileData?.subdataWithRange(dataRange))!

                AppTheme.DLog("writing packet number \(self.writingPacketNumber+1) ...");
                AppTheme.DLog("packet data: \(nextPacketData)");

                mConnectionController.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
                progress = 100.0
                percentage = Int(progress)
                AppTheme.DLog("DFUOperations: onTransferPercentage \(percentage)");
                mDelegate?.onTransferPercentage(percentage)
                self.writingPacketNumber++;
                mTimeoutTimer?.invalidate()
                AppTheme.DLog("DFUOperations: onAllPacketsTransfered");
                break;

            }
            let dataRange : NSRange = NSMakeRange(self.writingPacketNumber*enumPacketOption.PACKET_SIZE.rawValue, enumPacketOption.PACKET_SIZE.rawValue);

            let    nextPacketData : NSData  = (self.binFileData?.subdataWithRange(dataRange))!
            AppTheme.DLog("writing packet number \(self.writingPacketNumber+1) ...");
            AppTheme.DLog("packet data: \(nextPacketData)");

            mConnectionController.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
            progress = Double(self.writingPacketNumber * enumPacketOption.PACKET_SIZE.rawValue) / Double(self.binFileSize) * 100.0
            percentage = Int(progress)

            AppTheme.DLog("DFUOperations: onTransferPercentage \(percentage)");
            mDelegate?.onTransferPercentage(percentage)
            
            self.writingPacketNumber++;
        }
    }

    private func startSendingFile(){
        AppTheme.DLog("DFUOperationsdetails enablePacketNotification");
        mConnectionController.sendRequest(EnablePacketNotifyRequest())
        AppTheme.DLog("DFUOperationsdetails receiveFirmwareImage");
        mConnectionController.sendRequest(ReceiveFirmwareImageRequest())
  
        writeNextPacket()
        
        mDelegate?.onDFUStarted()
    }
    
    private func resetSystem(){
        AppTheme.DLog("DFUOperationsDetails resetSystem");
        mConnectionController.sendRequest(ResetSystemRequest())
    }
    
    private func validateFirmware(){
        AppTheme.DLog("DFUOperationsDetails validateFirmware");
        mConnectionController.sendRequest(ValidateFirmwareRequest())
    }

    private func activateAndReset(){
        AppTheme.DLog("DFUOperationsDetails activateAndReset");
        mConnectionController.sendRequest(ActivateAndResetRequest())
    }

    private func responseErrorMessage(errorCode:DfuOperationStatus.RawValue) ->NSString{
        switch (errorCode) {
        case DfuOperationStatus.OPERATION_FAILED_RESPONSE.rawValue:
            return NSString(string:"Operation Failed");

        case DfuOperationStatus.OPERATION_INVALID_RESPONSE.rawValue:
            return NSString(string:"Invalid Response");

        case DfuOperationStatus.OPERATION_NOT_SUPPORTED_RESPONSE.rawValue:
            return NSString(string:"Operation Not Supported");

        case DfuOperationStatus.DATA_SIZE_EXCEEDS_LIMIT_RESPONSE.rawValue:
            return NSString(string:"Data Size Exceeds");

        case DfuOperationStatus.CRC_ERROR_RESPONSE.rawValue:
            return NSString(string:"CRC Error");
            
        default:
            return NSString(string:"unknown Error");
            
        }
    }
    
    private func processRequestedCode(){
        AppTheme.DLog("processsRequestedCode");
        switch (dfuResponse.requestedCode) {
        case DfuOperations.START_DFU_REQUEST.rawValue:
            AppTheme.DLog("Requested code is StartDFU now processing response status");
            processStartDFUResponseStatus()
            break;
        case DfuOperations.RECEIVE_FIRMWARE_IMAGE_REQUEST.rawValue:
            AppTheme.DLog("Requested code is Receive Firmware Image now processing response status");
            processReceiveFirmwareResponseStatus()
            break;
        case DfuOperations.VALIDATE_FIRMWARE_REQUEST.rawValue:
            AppTheme.DLog("Requested code is Validate Firmware now processing response status");
            processValidateFirmwareResponseStatus()
            break;

        default:
            AppTheme.DLog("invalid Requested code in DFU Response \(dfuResponse.requestedCode)");
            break;
        }
    }
    
    private func processStartDFUResponseStatus(){
        AppTheme.DLog("processStartDFUResponseStatus");
        let errorMessage:NSString = "Error on StartDFU\n Message: \(responseErrorMessage(dfuResponse.responseStatus))"
        switch (dfuResponse.responseStatus) {
        case DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue:
            AppTheme.DLog("successfully received startDFU notification");
            startSendingFile()
            break;
        case DfuOperationStatus.OPERATION_NOT_SUPPORTED_RESPONSE.rawValue:
            AppTheme.DLog("device has old DFU. switching to old DFU ...");
            performOldDFUOnFile()
            break;

        default:
            AppTheme.DLog("StartDFU failed, Error Status: \(responseErrorMessage(dfuResponse.responseStatus))");
            mDelegate?.onError(errorMessage)
            resetSystem()
            break;
        }

    }
    
    private func processReceiveFirmwareResponseStatus(){
        AppTheme.DLog("processReceiveFirmwareResponseStatus");
        if (dfuResponse.responseStatus == DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue) {
            AppTheme.DLog("successfully received notification for whole File transfer");
            validateFirmware()
        }else {
            AppTheme.DLog("Firmware Image failed, Error Status: \(responseErrorMessage(dfuResponse.responseStatus))");
            let errorMessage = "Error on Receive Firmware Image\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
            mDelegate?.onError(errorMessage)
            resetSystem()
        }

    }
    
    private func processValidateFirmwareResponseStatus(){
        AppTheme.DLog("processValidateFirmwareResponseStatus");
        if (dfuResponse.responseStatus == DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue) {
            AppTheme.DLog("succesfully received notification for ValidateFirmware");
            activateAndReset()
            mDelegate?.onSuccessfulFileTranferred()
        }else {
            AppTheme.DLog("Firmware validate failed, Error Status: \( responseErrorMessage(dfuResponse.responseStatus))");
            let errorMessage = "Error on Validate Firmware Request\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
            mDelegate?.onError(errorMessage)
            resetSystem()
        }
    }
    
    private func processPacketNotification(){
        AppTheme.DLog("received Packet Received Notification");
        if (writingPacketNumber < numberOfPackets) {
            writeNextPacket()
        }
    }

    private func setDFUResponseStruct(data:[UInt8]){
        dfuResponse.responseCode = data[0]
        dfuResponse.requestedCode = data[1]
        dfuResponse.responseStatus = data[2]
    }
    
    private func processDFUResponse(data :[UInt8]){
        AppTheme.DLog("processDFUResponse");
        setDFUResponseStruct(data)
        
        if (dfuResponse.responseCode == DfuOperations.RESPONSE_CODE.rawValue) {
            processRequestedCode()
        }else if(dfuResponse.responseCode == DfuOperations.PACKET_RECEIPT_NOTIFICATION_RESPONSE.rawValue) {
            processPacketNotification()
        }
    }
    
    /*
    see ConnectionControllerDelegate protocol
    */
    func packetReceived(packet:RawPacket) {
        //dicard those packets from  NevoProfile
        if !(packet.getSourceProfile() is NevoProfile){
            if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION && mConnectionController.getOTAMode() == true){
                processDFUResponse(NSData2Bytes(packet.getRawData()))
            }else if(dfuFirmwareType == DfuFirmwareTypes.SOFTDEVICE) {
                SyncQueue.sharedInstance_ota.next()
                MCU_processDFUResponse(packet)
            }
        }
    }
    /*
    see ConnectionControllerDelegate protocol
    */
    func connectionStateChanged(isConnected : Bool) {

        mDelegate?.connectionStateChanged(isConnected)
        //only BLE OTA run below code
        if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION ){
            if isConnected{
                if state == DFUControllerState.SEND_RECONNECT{
                    state = DFUControllerState.SEND_START_COMMAND
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.mConnectionController.sendRequest(SetOTAModeRequest())
                    })

                }else if state == DFUControllerState.DISCOVERING{
                    state = DFUControllerState.SEND_FIRMWARE_DATA
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.mConnectionController.sendRequest(StartOTARequest())
                        self.mConnectionController.sendRequest(writeFileSizeRequest(filelength: self.binFileSize))
                    })
                }
            }else{
                if state == DFUControllerState.IDLE{
                    self.state = DFUControllerState.SEND_RECONNECT

                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.mConnectionController.connect()
                    })
                }else if state == DFUControllerState.SEND_START_COMMAND{
                    self.state = DFUControllerState.DISCOVERING
                    //reset it by BLE peer disconnect
                    self.mConnectionController.setOTAMode(false,Disconnect:false)

                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        AppTheme.DLog("***********again set OTA mode,forget it firstly,and scan DFU service*******")
                        //when switch to DFU mode, the identifier has changed another one
                        self.mConnectionController.forgetSavedAddress()
                        self.mConnectionController.setOTAMode(true,Disconnect:false)
                        self.mConnectionController.connect()
                    })
                }
            }
        }
            //only MCU OTA run below code
        else{
            if(isConnected){
                if self.state == DFUControllerState.SEND_RECONNECT{
                    self.state = DFUControllerState.SEND_START_COMMAND
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.mConnectionController.sendRequest(Mcu_SetOTAModeRequest())
                    })
                }
            }else{
                if self.state == DFUControllerState.IDLE{
                    self.state = DFUControllerState.SEND_RECONNECT
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {

                        self.mConnectionController.connect()
                    })
                }
            }
        }
    }
    /**
    See ConnectionControllerDelegate
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString){
        mDelegate?.firmwareVersionReceived(whichfirmware, version: version)
    }

    /**
    See ConnectionControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){
        mDelegate?.receivedRSSIValue(number)
    }

    func setConnectControllerDelegate2Self(){
        mConnectionController.setDelegate(self)
    }

    func performDFUOnFile(firmwareURL:NSURL , firmwareType:DfuFirmwareTypes){
        lastprogress = 0.0
        progress = 0.0
        mTimeoutTimer?.invalidate()
        mTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Double(MAX_TIME), target: self, selector:Selector("timeroutProc:"), userInfo: nil, repeats: true)
        
        mConnectionController.setDelegate(self)
        state = DFUControllerState.IDLE
        dfuFirmwareType = firmwareType
        firmwareFile = firmwareURL
        //Hex to bin and read it to buffer
        openFile(firmwareURL)
        //enable it done after doing discover service
        //[dfuRequests enableNotification];
        if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION ){
            mConnectionController.setOTAMode(true,Disconnect:true)
        }else if(dfuFirmwareType == DfuFirmwareTypes.SOFTDEVICE){
            mConnectionController.setOTAMode(true,Disconnect:true)
        }
    }
    
    func timeroutProc(timer:NSTimer){
        if lastprogress == progress  && progress != 100.0{
            AppTheme.DLog("* * * OTA timeout * * *")
            let errorMessage = NSLocalizedString("ota_timeout",comment: "") as NSString
            mDelegate?.onError(errorMessage)

        }else{
            lastprogress = progress
        }
    }

    private func performOldDFUOnFile(){
        if (self.dfuFirmwareType == DfuFirmwareTypes.APPLICATION){
            openFile(firmwareFile!)
            mConnectionController.sendRequest(StartOTAOldRequest())
            mConnectionController.sendRequest(writeFileSizeOldRequest(filelength: binFileSize))
        }else{
            let errorMessage :NSString  = "Old DFU only supports Application upload"
            mDelegate?.onError(errorMessage)
            resetSystem()
        }
    }
    
    func cancelDFU(){
        AppTheme.DLog("cancelDFU");
        if (self.dfuFirmwareType == DfuFirmwareTypes.APPLICATION){
            resetSystem()
        }
        mDelegate?.onDFUCancelled()
    }

    func sendRequest(r:Request) {
        //for MCU OTA, use send queue to control it
        if (self.dfuFirmwareType == DfuFirmwareTypes.SOFTDEVICE){
            SyncQueue.sharedInstance_ota.post( { (Void) -> (Void) in
                self.mConnectionController.sendRequest(r)
            } )
        }else{
            self.mConnectionController.sendRequest(r)
        }
    }

    //added for MCU OTA
    
    func MCU_openfirmware(firmwareURL:NSURL){
        let locData:NSData = NSData(contentsOfURL: firmwareURL)!;
        //remove first 16K bytes, remain 48k bytes
        let currentRange :NSRange =  NSMakeRange(16*1024, locData.length - 16 * 1024);

        firmwareDataBytesSent = 0
        curpage = 0
        binFileData = locData.subdataWithRange(currentRange)
        binFileSize = binFileData!.length
        totalpage = binFileData!.length/DFUCONTROLLER_PAGE_SIZE;
        checksum = 0
        dfuFirmwareType = DfuFirmwareTypes.SOFTDEVICE

        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(binFileData!.bytes), count:binFileData!.length)

        for  byte in bytes {
            checksum = checksum + Int(byte)
        }

        AppTheme.DLog("Set firmware with size \(binFileData!.length), notificationPacketInterval: \(notificationPacketInterval), totalpage: \(totalpage),Checksum: \(checksum)")

    }
    
    func MCU_sendFirmwareChunk(){
        AppTheme.DLog("sendFirmwareData")
        //define one page request  object
        let Onepage:Mcu_OnePageRequest = Mcu_OnePageRequest()

        for var i:Int = 0; i < notificationPacketInterval && firmwareDataBytesSent < binFileSize; i++ {
            var length = DFUCONTROLLER_MAX_PACKET_SIZE;
            var pagePacket : NSData;
            if( i == 0){
                //LSB format
                let pagehead :[UInt8] = [
                    00,0x71,
                    UInt8(curpage & 0xFF),
                    UInt8((curpage>>8) & 0xFF),
                    UInt8(totalpage & 0xFF),
                    UInt8((totalpage>>8) & 0xFF),
                    00,00,00,00,00,00,00,00,00,00,00,00,00,00]

                pagePacket = NSData(bytes: pagehead, length: pagehead.count)
            }else {
                if( i != (notificationPacketInterval - 1)){
                    length = DFUCONTROLLER_MAX_PACKET_SIZE;
                }else{
                    length = DFUCONTROLLER_PAGE_SIZE%DFUCONTROLLER_MAX_PACKET_SIZE;
                }

                let currentRange:NSRange = NSMakeRange(self.firmwareDataBytesSent, length)

                let currentData:NSData =  binFileData!.subdataWithRange(currentRange)

                let fulldata:NSMutableData = NSMutableData()

                if i == self.notificationPacketInterval - 1{
                    fulldata.appendBytes([0xFF,0x71] as [UInt8], length: 2)
                }else{
                    fulldata.appendBytes([UInt8(i),0x71] as [UInt8], length: 2)
                }

                fulldata.appendData(currentData)

                //last packet of the page, remains 8 bytes,fill 0
                if(i == (notificationPacketInterval - 1)){
                    fulldata.appendBytes([0,0,0,0,0,0,0,0] as [UInt8], length: 8)
                }
                pagePacket = fulldata

                firmwareDataBytesSent += length;
            }

            Onepage.addPacket(Mcu_OnePacketRequest(packetdata: pagePacket ))
        }

        if(curpage < totalpage){
            sendRequest(Onepage)
            progress = 100.0*Double(firmwareDataBytesSent) / Double(binFileSize);
            mDelegate?.onTransferPercentage(Int(progress))
            AppTheme.DLog("didWriteDataPacket")

            if (state == DFUControllerState.SEND_FIRMWARE_DATA){
                curpage++
                state = DFUControllerState.WAIT_RECEIPT
            }
            
        }else{
            state = DFUControllerState.FINISHED
            progress = 100.0
            mDelegate?.onTransferPercentage(Int(progress))
            sendRequest(Mcu_CheckSumPacketRequest(totalpage: totalpage, checksum: checksum))        
            AppTheme.DLog("sendEndPacket, totalpage =\(totalpage), checksum = \(checksum), checksum-Lowbyte = \(checksum&0xFF)")
            mTimeoutTimer?.invalidate()
            return
        }
        AppTheme.DLog("Sent \(self.firmwareDataBytesSent) bytes, pageno: \(curpage).")
    }
    
    func MCU_processDFUResponse(packet:RawPacket){
        AppTheme.DLog("didReceiveReceipt")
        mPacketsbuffer.append(packet.getRawData())
        var databyte:[UInt8] = NSData2Bytes(packet.getRawData())
        
        if(databyte[0] == 0xFF){
            if( databyte[1] == 0x70){
                //first Packet  as header get successful response!
                progress = Double(firmwareDataBytesSent) / Double(binFileSize)
                self.state = DFUControllerState.SEND_FIRMWARE_DATA
               
            }

            if( databyte[1] == 0x71 && self.state == DFUControllerState.FINISHED){
                var databyte1:[UInt8] = NSData2Bytes(mPacketsbuffer[0])
                
                if(databyte1[1] == 0x71
                    && databyte1[2] == 0xFF
                    && databyte1[3] == 0xFF
                    ){
                    let TotalPageLo:UInt8 = UInt8(totalpage & 0xFF)
                    let TotalPageHi:UInt8 = UInt8((totalpage>>8) & 0xFF)
                    
                    if (databyte1[4] == TotalPageLo
                        && databyte1[5] == TotalPageHi){
                        //Check sum match ,OTA over.
                        AppTheme.DLog("Checksum match ,OTA get success!");
                        mDelegate?.onSuccessfulFileTranferred()
                    }else{
                        AppTheme.DLog("Checksum error ,OTA get failure!");
                        mDelegate?.onError(NSString(string:"Checksum error ,OTA get failure!"))
                    }
                }
            }
            
            mPacketsbuffer = []
            
            if (self.state == DFUControllerState.SEND_FIRMWARE_DATA){
                MCU_sendFirmwareChunk()
            }else if(self.state == DFUControllerState.WAIT_RECEIPT){
                self.state = DFUControllerState.SEND_FIRMWARE_DATA;
                MCU_sendFirmwareChunk()
            }
        }
    }
    //end added
    
    func isConnected() -> Bool{
        return mConnectionController.isConnected()
    }

    func setStatus(state:DFUControllerState){
      self.state = state
    }

    func getStatus() ->DFUControllerState{
        return state
    }

    /**
    reset to normal mode "NevoProfile"
    parameter: switch2SyncController: true/false
    step1: restore Address
    step2: restore syncController
    step3: restore normal mode
    step4: reconnect
    //from OTA mode to normal mode, must make syncController to handle connectionController
    because MCU/BLE ota, user has done one of them, perhaps do another one,
    so no need make syncController handle connectionController
    */
    func reset(switch2SyncController:Bool){
        mTimeoutTimer?.invalidate()
        //reset it to INIT status !!!IMPORTANT!!!
        self.state = DFUControllerState.INIT
        
        if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION ){
            self.mConnectionController.restoreSavedAddress()
        }

        if switch2SyncController{
            self.mConnectionController.setDelegate(AppDelegate.getAppDelegate())
        }
        self.mConnectionController.setOTAMode(false,Disconnect:true)
        self.mConnectionController.connect()
    }
    
    /**
    See ConnectionController protocol
    */
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController.getFirmwareVersion() : NSString()
    }
    
    /**
    See ConnectionController protocol
    */
    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController.getSoftwareVersion() : NSString()
    }

}

/**
this protocol is defined for OTA UIView controller
*/
protocol NevoOtaControllerDelegate {
    
    func connectionStateChanged(isConnected : Bool)
    func onDFUStarted()
    func onDFUCancelled()
    func onTransferPercentage(_: Int)
    func onSuccessfulFileTranferred()
    func onError(errorMessage: NSString)
    /**
    Call when finished OTA, will reconnect nevo and read firmware, refresh the firmware  to screen view
    @parameter whichfirmware, firmware type
    @parameter version, return the version
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber)
}
