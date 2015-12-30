//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 12/29/15.
//  Copyright © 2015 Richard Shi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    //MARK: Properties
    let labelBorderWidth = 2
    let selectionBorderWidth:CGFloat = 5
    let pointerSize:CGFloat = 20

    let barCodeTypes = [AVMetadataObjectTypeUPCECode,
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
    
    var session:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var selectionView:UIView?
    
    @IBOutlet weak var labelBarcodeResult: UILabel!
    @IBOutlet var mainView: UIView!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set capture device
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError? = nil    //Possible Error to be thrown
        let captureDeviceInput:AnyObject?
        
        //Tries to get device input, shows alert if theres an error
        do{
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
        } catch let someError as NSError{
            error = someError   //get Error to throw
            captureDeviceInput = nil
        }
        
        //Shows Error if failure to get Input
        if error != nil{
            let alertView:UIAlertView = UIAlertView(title: "Device Error", message:"Device not Supported", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        //Creates capture session and adds input
        self.session = AVCaptureSession()
        self.session?.addInput(captureDeviceInput as! AVCaptureInput)

        //Adds metadata output to session
        let metadataOutput = AVCaptureMetadataOutput()
        self.session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        metadataOutput.metadataObjectTypes = barCodeTypes

        //Add the video preview layer to the main view
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.frame = self.view.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(videoPreviewLayer!)
        
        //Run session with the label put in front
        self.session?.startRunning()
        self.view.bringSubviewToFront(labelBarcodeResult)
        
        //creates the selection view
        self.selectionView = UIView()
        self.selectionView?.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        self.selectionView?.layer.borderColor = UIColor.redColor().CGColor
        self.selectionView?.layer.borderWidth = selectionBorderWidth
        self.selectionView?.frame = CGRectMake(0,0, pointerSize , pointerSize)
        self.selectionView?.center = CGPointMake(CGRectGetMidX(mainView.bounds), CGRectGetMidY(mainView.bounds))

        //adds the selection view
        self.view.addSubview(selectionView!)
        self.view.bringSubviewToFront(selectionView!)
    }
    
    func validateURL(url:String)->Bool{
        if let testURL = NSURL(string: url){
            return UIApplication.sharedApplication().canOpenURL(testURL)
        }
        return false
    }
    
    func validateBarcode(barCode:String)->Bool{
        return false    //TODO
    }
    
    //MARK: Actions
    @IBAction func OpenURLInBrowser(sender: UITapGestureRecognizer) {
        let label:UILabel = sender.view as! UILabel
        if let url = label.text{
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)  //Opens link in browser
        }
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            
            //Draw and center pointer
            selectionView?.frame = CGRectMake(0,0, pointerSize , pointerSize)
            selectionView?.center = CGPointMake(CGRectGetMidX(mainView.bounds), CGRectGetMidY(mainView.bounds))
            selectionView?.layer.borderColor = UIColor.redColor().CGColor
            
            //Reset Label
            labelBarcodeResult.text = "No Barcode detected"
            labelBarcodeResult.textColor = UIColor.redColor()
            labelBarcodeResult.userInteractionEnabled = false

            return
        }
        
        let metadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        for barCodeType in barCodeTypes{
            if metadataMachineReadableCodeObject.type == barCodeType {
                let barCode = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                
                //Set selection to the barcode's bounds
                selectionView?.frame = barCode.bounds;
                selectionView?.layer.borderColor = UIColor.greenColor().CGColor
                
                //Sets the label text to the value of the bar code object
                if metadataMachineReadableCodeObject.stringValue != nil {
                    labelBarcodeResult.text = metadataMachineReadableCodeObject.stringValue
                    
                    //If valid URL turns text blue and makes it tappable
                    if metadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode && validateURL(labelBarcodeResult.text!){
                        selectionView?.layer.borderColor = UIColor.blueColor().CGColor
                        labelBarcodeResult.textColor = UIColor.blueColor()
                        labelBarcodeResult.userInteractionEnabled = true
                    } else{
                        labelBarcodeResult.textColor = UIColor.greenColor()
                        labelBarcodeResult.userInteractionEnabled = false
                    }
                }
            }

        }
    }
}

