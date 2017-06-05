//
//  CameraFrameViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 6/4/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import AVFoundation

class CameraFrameViewController: UIViewController {
    @IBOutlet weak var takePhotoButton: UIButton!

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mileLabel: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finishButton.layer.cornerRadius = CGFloat(Constants.round)
        finishButton.clipsToBounds = true
        finishButton.isHidden = true
        
        finishButton.isEnabled = false
        
        mileLabel.layer.cornerRadius = 3
        
        takePhotoButton.layer.cornerRadius = 30
        takePhotoButton.layer.borderColor = Colors.black.cgColor 
        takePhotoButton.layer.borderWidth = 3
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        // Do any additional setup after loading the view.
        
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.back) {
                        captureDevice = device
                        if captureDevice != nil {
                            print("Capture device found")
                            beginSession()
                        }
                    }
                }
            }
        }
        
    }
    
    func beginSession() {
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
            print("no preview layer")
            return
        }
        
        self.previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.previewView.layer.frame
        captureSession.startRunning()

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: UIButton) {
        finishButton.isEnabled = true
        finishButton.backgroundColor = Colors.green
        finishButton.isHidden = false
        
    }
    
    @IBAction func finishButton(_ sender: Any) {
        self.performSegue(withIdentifier: "home", sender: nil)
    }
    
      
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Back"
    }
    

}
