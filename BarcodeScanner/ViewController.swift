//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 12/29/15.
//  Copyright © 2015 Richard Shi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    //MARK: Properties
    let labelBorderWidth = 2
    let selectionBorderWidth:CGFloat = 5
    let pointerSize:CGFloat = 20
    
    let barcodeTypes = [AVMetadataObjectTypeUPCECode,
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
    
    // @IBOutlet weak var labelBarcodeResult: UILabel!
    @IBOutlet var barcodeResultButton: UIBarButtonItem!
    @IBOutlet weak var barcodeToolbar: UIToolbar!
    
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
        session = AVCaptureSession()
        session?.addInput(captureDeviceInput as! AVCaptureInput)
        
        //Get metadata output from session
        let metadataOutput = AVCaptureMetadataOutput()
        session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        metadataOutput.metadataObjectTypes = barcodeTypes
        
        //Add the video preview layer to the main view
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.frame = self.view.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)
        
        //Run session
        session?.startRunning()
        
        //creates the selection box
        selectionView = UIView()
        selectionView?.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        selectionView?.layer.borderColor = UIColor.redColor().CGColor
        selectionView?.layer.borderWidth = selectionBorderWidth
        selectionView?.frame = CGRectMake(0,0, pointerSize , pointerSize)
        selectionView?.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        
        //Set up toolbar
        self.view.bringSubviewToFront(barcodeToolbar)
        barcodeResultButton.enabled = false
        
        //adds the selection box to main View
        self.view.addSubview(selectionView!)
        self.view.bringSubviewToFront(selectionView!)
    }
    
    //Validates the URL to see if it is opennable with any application on the device
    func validateURL(url:String)->Bool{
        if let testURL = NSURL(string: url){
            return UIApplication.sharedApplication().canOpenURL(testURL)
        }
        return false
    }
    
    //resets view to default
    func resetToDefault(){
        selectionView?.frame = CGRectMake(0,0, pointerSize , pointerSize)
        selectionView?.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        selectionView?.layer.borderColor = UIColor.redColor().CGColor
        
        //Reset result button
        barcodeResultButton.title = "No Barcode detected"
        barcodeResultButton.enabled = false
    }
    
    //MARK: Actions
    @IBAction func DisplayBarcodeMenu(sender: UIBarButtonItem) {
        let barcodeMessage:String? = "Barcode: " + sender.title! ?? ""
        let actionSheetMenu = UIAlertController(title: barcodeMessage, message: nil, preferredStyle: .ActionSheet)
        
        //Pauses the video capture session
        session?.stopRunning()
        
        //Adds menu item to follow link if valid link
        if validateURL(sender.title!){
            let followLinkAction = UIAlertAction(title: "Follow Link", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = sender.title{
                    UIApplication.sharedApplication().openURL(NSURL(string: url)!)  //Opens link in browser
                }
                self.resetToDefault()
                self.session?.startRunning()
            })
            actionSheetMenu.addAction(followLinkAction)
        }
        
        //Copies text to clipboard
        let copyAction = UIAlertAction(title: "Copy to Clipboard", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIPasteboard.generalPasteboard().string = sender.title
            self.resetToDefault()
            self.session?.startRunning()
        })
        actionSheetMenu.addAction(copyAction)
        
        //Cancels menu
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.resetToDefault()
            self.session?.startRunning()
        })
        actionSheetMenu.addAction(cancelAction)
        
        //Presents the Action Sheet Menu
        self.presentViewController(actionSheetMenu, animated: true, completion: nil)
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            self.resetToDefault()
            return
        }
        
        //Get each metadataObject and check if it is a barcode type
        let metadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        for barcodeType in barcodeTypes{
            if metadataMachineReadableCodeObject.type == barcodeType {
                let barcode = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                
                //Set selection to the barcode's bounds
                selectionView?.frame = barcode.bounds;
                selectionView?.layer.borderColor = UIColor.greenColor().CGColor
                
                //Sets the result button text to the value of the bar code object
                if metadataMachineReadableCodeObject.stringValue != nil {
                    barcodeResultButton.title = metadataMachineReadableCodeObject.stringValue
                    barcodeResultButton.enabled = true
                } else{
                    barcodeResultButton.title = "Barcode not recognised"
                }
            }
            
        }
    }
}

