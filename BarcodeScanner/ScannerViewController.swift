//
//  ScannerViewController.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, HistoryViewControllerDelegate, CaptureManagerDelegate {

    //MARK: Properties
    var dataModel:DataModel!
    var captureManager:CaptureManager!
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    var selectionView:UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    //@IBOutlet weak var codeButton: UIBarButtonItem!
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true;
        }
    }
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        captureManager = CaptureManager()
        captureManager.delegate = self
        captureManager.setupCaptureSession()
        captureManager.session?.startRunning()
        
        //Create AV Video Preview layer and add to view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureManager.session!)
        previewLayer?.frame = self.view.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.viewWithTag(666)?.layer.addSublayer(previewLayer!)
        
        //creates the selection box
        selectionView = UIView()
        selectionView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]

        resetSelectionView()
        
        //adds the selection box to main View
        view.addSubview(selectionView)
        view.bringSubview(toFront: selectionView)
        
        view.bringSubview(toFront: toolbar)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHistory"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! HistoryViewController
            
            controller.dataModel = dataModel        //ugh
            controller.delegate = self
        }
    }
    
    //resets view to default
    func resetSelectionView(){
        selectionView?.frame = CGRect(x: 0,y: 0, width: 20 , height: 20)
        selectionView?.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        selectionView.layer.borderWidth = 5
        selectionView?.layer.borderColor = UIColor.red.cgColor
    }
    
    //MARK: CaptureManagerDelegate
    func captureManager(_ manager: CaptureManager,
                        didDetect codeObject: AVMetadataMachineReadableCodeObject){
        
        let barcode = previewLayer?.transformedMetadataObject(for: codeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
        
        //Set selection to the barcode's bounds
        selectionView?.frame = barcode.bounds;
        selectionView?.layer.borderColor = UIColor.green.cgColor
        

        if codeObject.stringValue != nil {
            let type = codeObject.type.components(separatedBy: ".").last
          //  codeButton.title = type! + ": " + codeObject.stringValue
        }
    }
    
    func captureManagerDidNotDetect(_ manager: CaptureManager) {
        resetSelectionView()
    }

    //MARK: HistoryViewControllerDelegate
    func historyViewControllerDidReturn(_ controller: HistoryViewController){
        dismiss(animated: true, completion: nil)
    }
    
    func historyViewController(_ controller: HistoryViewController,
                               didFinishEditing checklist: CodeItem){
        
    }
    
    func validateURL(_ url:String)->Bool{
        if let testURL = URL(string: url){
            return UIApplication.shared.canOpenURL(testURL)
        }
        return false
    }
}
