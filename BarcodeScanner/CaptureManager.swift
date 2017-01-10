//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//
import Foundation
import AVFoundation

protocol CaptureManagerDelegate:class {
    func captureManagerDidNotDetect(_ manager: CaptureManager)
    func captureManager(_ manager: CaptureManager,
                                  didDetect codeObject: AVMetadataMachineReadableCodeObject)
}

class CaptureManager: NSObject, AVCaptureMetadataOutputObjectsDelegate{
    //MARK: Properties
    
    weak var delegate:CaptureManagerDelegate?
    var session:AVCaptureSession?
    
    let supportedBarcodeTypes = [
        AVMetadataObjectTypeDataMatrixCode,
        AVMetadataObjectTypeInterleaved2of5Code,
        AVMetadataObjectTypeITF14Code,
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeQRCode,
        AVMetadataObjectTypeAztecCode
    ]
    
    func setupCaptureSession() {
        //Set capture device
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let captureDeviceInput:AnyObject?
        
        //Try to get device input
        do{
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
        } catch let error as NSError{
            print("Error code: \(error)")
            captureDeviceInput = nil
            return
        }
        
        //Creates capture session and adds input
        session = AVCaptureSession()
        session?.addInput(captureDeviceInput as! AVCaptureInput)
        
        //Get metadata output from session
        let metadataOutput = AVCaptureMetadataOutput()
        session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = supportedBarcodeTypes
        
        //delegate?.captureManagerDidStart(self)
    }
    
    func runSession(){
        session?.startRunning()
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            delegate?.captureManagerDidNotDetect(self)
            return
        }
        
        //Get each metadataObject and check if it is a barcode type
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        for barcodeType in supportedBarcodeTypes{
            if metadataObject.type == barcodeType {   //Barcode detected
                delegate?.captureManager(self, didDetect: metadataObject)
            }
        }
    }
}
