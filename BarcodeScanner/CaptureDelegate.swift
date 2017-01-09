//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//
import Foundation
import AVFoundation

class CaptureDelegate: AVCaptureMetadataOutputObjectsDelegate{
    
    //MARK: Properties
    let labelBorderWidth = 2
    let selectionBorderWidth:CGFloat = 5
    let pointerSize:CGFloat = 20
    
    let barcodeTypes = [
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
    
    var session:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var selectionView:UIView?
    
    // @IBOutlet weak var labelBarcodeResult: UILabel!
    @IBOutlet var barcodeResultButton: UIBarButtonItem!
    @IBOutlet weak var barcodeToolbar: UIToolbar!
    @IBOutlet weak var logoLabel: UILabel!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set capture device
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
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
        selectionView?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        selectionView?.layer.borderColor = UIColor.red.cgColor
        selectionView?.layer.borderWidth = selectionBorderWidth
        selectionView?.frame = CGRect(x: 0,y: 0, width: pointerSize , height: pointerSize)
        selectionView?.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        
        //Set up toolbar
        view.bringSubview(toFront: barcodeToolbar)
        barcodeResultButton.isEnabled = false
        
        //adds the selection box to main View
        view.addSubview(selectionView!)
        view.bringSubview(toFront: selectionView!)
        
    }
    
    //Validates the URL to see if it is opennable with any application on the device
    func validateURL(_ url:String)->Bool{
        if let testURL = URL(string: url){
            return UIApplication.shared.canOpenURL(testURL)
        }
        return false
    }
    
    //resets view to default
    func resetToDefault(){
        selectionView?.frame = CGRect(x: 0,y: 0, width: pointerSize , height: pointerSize)
        selectionView?.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        selectionView?.layer.borderColor = UIColor.red.cgColor
        
        //Reset result button
        barcodeResultButton.title = "No Barcode detected"
        barcodeResultButton.isEnabled = false
    }
    
    //MARK: Actions
    @IBAction func DisplayBarcodeMenu(_ sender: UIBarButtonItem) {
        let type = sender.title?.components(separatedBy: ": ").first
        let value = sender.title?.components(separatedBy: ": ").last
        let actionSheetMenu = UIAlertController(title: "Type: \(type!)", message: value!, preferredStyle: .actionSheet)
        
        //Pauses the video capture session
        session?.stopRunning()
        
        //Adds menu item to follow link if valid link
        if validateURL(value!){
            let followLinkAction = UIAlertAction(title: "Follow Link", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if let url = value{
                    UIApplication.shared.openURL(URL(string: url)!)  //Opens link in browser
                }
                self.resetToDefault()
                self.session?.startRunning()
            })
            actionSheetMenu.addAction(followLinkAction)
        }
        
        //Copies text to clipboard
        let copyAction = UIAlertAction(title: "Copy to Clipboard", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIPasteboard.general.string = value!
            self.resetToDefault()
            self.session?.startRunning()
        })
        actionSheetMenu.addAction(copyAction)
        
        //Cancels menu
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.resetToDefault()
            self.session?.startRunning()
        })
        actionSheetMenu.addAction(cancelAction)
        
        //Presents the Action Sheet Menu
        self.present(actionSheetMenu, animated: true, completion: nil)
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            self.resetToDefault()
            return
        }
        
        //Get each metadataObject and check if it is a barcode type
        let metadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        for barcodeType in barcodeTypes{
            if metadataMachineReadableCodeObject.type == barcodeType {
                let barcode = videoPreviewLayer?.transformedMetadataObject(for: metadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                
                //Set selection to the barcode's bounds
                selectionView?.frame = barcode.bounds;
                selectionView?.layer.borderColor = UIColor.green.cgColor
                
                //Sets the result button text to the value of the bar code object
                if metadataMachineReadableCodeObject.stringValue != nil {
                    let type = metadataMachineReadableCodeObject.type.components(separatedBy: ".").last
                    barcodeResultButton.title = type! + ": " + metadataMachineReadableCodeObject.stringValue
                    barcodeResultButton.isEnabled = true
                } else{
                    barcodeResultButton.title = "Barcode not recognised"
                }
            }
            
        }
    }
    
}
