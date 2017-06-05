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
    
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finishButton.layer.cornerRadius = CGFloat(Constants.round)
        finishButton.clipsToBounds = true
        finishButton.isHidden = true
        
        finishButton.isEnabled = false
        
        mileLabel.layer.cornerRadius = 3
        
        takePhotoButton.layer.cornerRadius = 30
        takePhotoButton.layer.borderColor = Colors.black.cgColor        
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        captureSession.startRunning()
        
        
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDuoCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.front){
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            previewView.layer.addSublayer(previewLayer);
                        }
                    }
                }
                catch{
                    print("exception!");
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = previewView.bounds
    }
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    

}
