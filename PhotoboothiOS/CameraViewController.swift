//
// Copyright (C) 2015 Twitter, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import MobileCoreServices
import TwitterKit
import AVFoundation

class CameraViewController: BoothViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate /*, UITextViewDelegate */ {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var canvasImage: UIImageView!
    @IBOutlet weak var countdown: UILabel!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput : AVCaptureStillImageOutput?
    var startTime = TimeInterval()
    var timer = Timer()
    var snapTime:Double = 4
    var captureDevice : AVCaptureDevice?
    var imageOrientation: UIImageOrientation?
    var videoConnection : AVCaptureConnection? // find video connection
    var takingPhoto = false

    func startSnap() {

        if self.takingPhoto {
            return
        }
        
        self.takingPhoto = true
        self.countdown.alpha = 0.6

        let aSelector : Selector = #selector(CameraViewController.updateTime)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = Date.timeIntervalSinceReferenceDate
        
    }
    
    func updateTime() {
        
        self.cameraButton.isHidden = true
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        var elapsedTime = currentTime - startTime
        let seconds = snapTime - elapsedTime
        
        if seconds > 0 {
            
            elapsedTime -= TimeInterval(seconds)
            self.countdown.isHidden = false
            self.countdown.text = "\(Int(seconds+1))"
            
        } else {
            
            self.countdown.isHidden = true
            timer.invalidate()
            
            guard (self.stillImageOutput != nil) else {
                
                showMessage("No camera is available", okaction: { _ in }, completion: { _ in })
                return
            }
            
            // we are ready to save some photos
            // setup still OutPut to save
            if let stillOutput = self.stillImageOutput {
                
                // we do this on another thread so we don't hang the UI
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    
                    for connection in stillOutput.connections {
                        // find a matching input port
                        for port in (connection as AnyObject).inputPorts! {
                            // and matching type
                            if (port as AnyObject).mediaType == AVMediaTypeVideo {
                                self.videoConnection = connection as? AVCaptureConnection
                                break
                            }
                        }
                        if self.videoConnection != nil {
                            break // for connection
                        }
                    }
                    
                    if self.videoConnection != nil {
                        
                        // found the video connection, let's get the image
                        let _ = stillOutput.connection(withMediaType: AVMediaTypeVideo)
                        stillOutput.captureStillImageAsynchronously(from: self.videoConnection) {
                            (imageSampleBuffer:CMSampleBuffer!, _) in
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                            self.didTakePhoto(imageData!)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    func showMessage(_ message:String, okaction:@escaping (_ action:UIAlertAction) -> Void,
                                     completion:@escaping ()->Void) {
        
        let alertController = UIAlertController(title: "Default Style", message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: okaction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: completion)
    }
    
    func didTakePhoto(_ imageData: Data) {

        print("did take photo:")
        
        if let image = UIImage(data: imageData) {
        
            if let orientation = imageOrientation {
                
                self.canvasImage.image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: orientation)
            } else {
                
                self.canvasImage.image = image
            }
            
            //gpj
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let destinationPath = (documentsPath as NSString).appendingPathComponent("photobooth.jpg")
            
            if let rawData = UIImageJPEGRepresentation(image, 1.0) {
                
                try? rawData.write(to: URL(fileURLWithPath: destinationPath), options: [.atomic])
            }
            
            self.canvasImage.isHidden = false
            self.cameraButton.isHidden = false
            self.view.bringSubview(toFront: canvasImage)
            
            // after photo, go directly to preview
            preview()
            
        }
        
        self.takingPhoto = false
        
    }
    
    func preview() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            //self.captureSession.stopRunning()
            self.canvasImage.isHidden = true
        }
        
        self.performSegue(withIdentifier: "preview", sender: self);
    }
    
    func setupCam() {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],mediaType: AVMediaTypeVideo,position: AVCaptureDevicePosition.front) {
            
            for device in deviceDescoverySession.devices {
                captureDevice = device as AVCaptureDevice
                if captureDevice != nil {
                    print("Capture device found")
                    
                    beginSession()
                }
                }
        }

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.cameraButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        super.setupNav(false, enableSettings : true)
        self.setupCam()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.setRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    func focusTo(_ value : Float) {
        if let device = captureDevice, let _ = try? device.lockForConfiguration() {
            
            device.unlockForConfiguration()
        }
    }
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    // TODO: clean this
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
        stillImageOutput!.outputSettings = outputSettings
        
        // add output to session
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        do {
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error as NSError{
            
            print("error: \(error.localizedDescription)")
        }
        
        // create camera preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let preview = previewLayer  {
            
            self.view.layer.addSublayer(preview)
        }
        
        // prepare for the countdown
        self.view.bringSubview(toFront: countdown)
        
        // add camera button
        self.view.bringSubview(toFront: cameraButton)
        let tap = UITapGestureRecognizer(target:self, action:#selector(CameraViewController.startSnap))
        self.view.addGestureRecognizer(tap)
        
        // set rotation
        self.setRotation()

        captureSession.startRunning()
    }

    // gpj
    func setRotation() {
        
        let device = UIDevice.current

        if (device.orientation == UIDeviceOrientation.landscapeLeft){
            print("landscape left")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            imageOrientation = UIImageOrientation.downMirrored
            
        } else if (device.orientation == UIDeviceOrientation.landscapeRight){
            print("landscape right")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            imageOrientation = UIImageOrientation.upMirrored
            
        } else if (device.orientation == UIDeviceOrientation.portrait){
            print("Portrait")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
            imageOrientation = UIImageOrientation.leftMirrored
            
        } else if (device.orientation == UIDeviceOrientation.portraitUpsideDown){
            print("Portrait UD")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            imageOrientation = UIImageOrientation.rightMirrored
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let bounds = view.layer.bounds;
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer?.bounds = bounds;
        previewLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {

        if segue.identifier == "preview" {
            
            guard imageOrientation != nil else {
                
                return
            }
            let vc = segue.destination as! PreviewViewController
            vc.imageOrientation = imageOrientation!
        }
        
    }
    
    
    @IBAction func touchUpInsideCameraButton(_ sender: AnyObject) {
        self.startSnap()
    }
    
    func showSettings() {
        
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController") 
            self.show(controller, sender: self)
        });
        
    }

    
}
