//
//  CameraOverlayCollectionViewController.swift
//  Shelf
//
//  Created by Matthew James on 17/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class CameraOverlayVC: UIViewController {
    let screenSize = UIScreen.main.bounds.size
    let kTabBarHeight = CGFloat(90)
    var reviewAndCropCenter : CGFloat!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var cameraAccessView: UIView!
    var cropVC : TOCropViewController!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput :AVCaptureStillImageOutput?
    var imagePicker = UIImagePickerController()
    
    var flashButtonItem : UIBarButtonItem?
    var backButtonItem : UIBarButtonItem!
    var currFlashImage: UIImage?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    @IBOutlet weak var captureAColor: UILabel!
    @IBOutlet weak var reviewAndCrop: UILabel!
    
    @IBOutlet weak var captureButtonsView: UIView!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var existingPhotosButton: UIButton!
    
    @IBOutlet weak var cropButtonsView: UIView!
    @IBOutlet weak var retake: UIButton!
    @IBOutlet weak var looksGreat: UIButton!
    
    var pickedImage : UIImage?

    @IBOutlet weak var captureAColorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setTitleAttributedString()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        checkRequestCamera()
        
        setupNewTabBarAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
        updateFlashButtonImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter?.isHidden = true
        
        previewLayer?.frame = CGRect(x: 0, y: 0, width: cameraPreviewView.width, height: cameraPreviewView.height)
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: cameraPreviewView.height )
    }
    
    // MARK: - Setup helper functions
    func setTitleAttributedString() {
        let captureString: NSMutableAttributedString = NSMutableAttributedString(string: "CAPTURE")
        captureString.addAttribute(NSKernAttributeName, value: 7.4, range: NSMakeRange(0, captureString.length))
        captureAColor.attributedText = captureString
        
        let reviewString = NSMutableAttributedString(string: "REVIEW & CROP")
        reviewString.addAttribute(NSKernAttributeName, value: 6.7, range: NSMakeRange(0, reviewString.length))
        reviewAndCrop.attributedText = reviewString
    }
    
    func checkRequestCamera() {
        // Request Camera
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            checkForCamera()
        }
        else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async(execute: {
                    if granted {
                        self.checkForCamera()
                    }
                    else {
                            self.cameraAccessView.isHidden = false
                    }
                })
            })
        }
    }
    
    func checkForCamera() {
        var hasFrontCamera = false
        var hasBackCamera = false
        
        // Loop through all the capture devices on this phone
        let devices = AVCaptureDevice.devices()
        for device in devices! {
            // Make sure this particular device supports video
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                // Finally check the position and confirm we've got the back camera
                if (device as AnyObject).position == AVCaptureDevicePosition.back {
                    captureDevice = device as? AVCaptureDevice
                    hasBackCamera = true
                }
                else if (device as AnyObject).position == AVCaptureDevicePosition.front {
                    hasFrontCamera = true
                    if let _ = captureDevice {
                        
                    }
                    else {
                        captureDevice = device as? AVCaptureDevice
                    }
                }
            }
        }
        
        // Device have front camera
        if hasFrontCamera {
            // Device have back camera too, enable switchCameraButton
            if hasBackCamera {
                switchCameraButton.isUserInteractionEnabled = true
                switchCameraButton.alpha = 1
            }
            // Device only have front camera
            else {
                // DO NOTHING?
            }
            setupCamera()
        }
        // Device doesn't have front camera
        else {
            // Device only have back camera
            if hasBackCamera {
                setupCamera()
            }
            // Device doesn't have back camera either
            else {
                cameraAccessView.isHidden = false
            }
        }
    }
    
    func setupCamera() {
        guard let captureDevice = captureDevice else {
            return
        }
        
//        captureButton.hidden = false
        captureButton.isUserInteractionEnabled = true
        captureButton.alpha = 1
        
        // Check if camera flash is supported
        if captureDevice.hasFlash && captureDevice.hasTorch {
            flashButtonItem?.isEnabled = true
        }
        
        print("Capture device found")
        do {
            try captureDevice.lockForConfiguration()
        } catch _ {
            
        }
        
        if captureDevice.isFlashModeSupported(AVCaptureFlashMode.off) {
            captureDevice.flashMode = AVCaptureFlashMode.off
        }
        captureDevice.unlockForConfiguration()
        beginSession()
    }
   
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 55.0, height: 30.0)
        navigationItem.titleView = titleView
        
        currFlashImage = UIImage(named: "flashOffButton")
        flashButtonItem = UIBarButtonItem(image: currFlashImage, style: .plain, target: self, action: #selector(CameraOverlayVC.flashButtonPressed(_:)))
        flashButtonItem?.isEnabled = false
        flashButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = flashButtonItem

        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        cancelButton.setImage(UIImage(named: "cancelButton"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(CameraOverlayVC.cancelButtonPressed(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(CameraOverlayVC.backButtonPressed(_:)), for: .touchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
    }
    
    func setupNewTabBarAppearance() {
        looksGreat.layer.cornerRadius = 10
        looksGreat.clipsToBounds = true
        
        retake.layer.cornerRadius = 10
        retake.clipsToBounds = true
    }

    // MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter?.isHidden = false
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        retakeButtonPressed(sender)
    }
    
    @IBAction func flashButtonPressed(_ sender: AnyObject) {
        if(captureDevice?.flashMode == AVCaptureFlashMode.off) {
            do {
                try captureDevice?.lockForConfiguration()
            } catch _ {
            }
            if captureDevice!.isFlashModeSupported(AVCaptureFlashMode.on) {
                captureDevice?.flashMode = AVCaptureFlashMode.on
            }
            captureDevice?.unlockForConfiguration()
        } else {
            do {
                try captureDevice?.lockForConfiguration()
            } catch _ {
            }
            if captureDevice != nil && captureDevice!.isFlashModeSupported(AVCaptureFlashMode.off) {
                captureDevice?.flashMode = AVCaptureFlashMode.off
            }
            captureDevice?.unlockForConfiguration()
        }
        
        updateFlashButtonImage()
    }
    
    @IBAction func galleryButtonPressed(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            //show image picker
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        if let stillOutput = stillImageOutput {
            // we do this on another thread so that we don't hang the UI
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                //find the video connection
                if let videoConnection = self.getVideoConnection(stillOutput) {
                    stillOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageSampleBuffer, error) -> Void in
                        guard error == nil else {
                            print(error.debugDescription)
                            return
                        }
                        
                        self.captureButton.isUserInteractionEnabled = false
                        self.captureImage(imageSampleBuffer!)
                    })
                }
            }
        }
    }
    
    @IBAction func switchCameraButtonPressed(_ sender: AnyObject) {
        //Indicate that some changes will be made to the session
        captureSession.beginConfiguration()
        
        if captureSession.inputs.count > 0 {
            //Remove existing input
            let currentCameraInput = captureSession.inputs[0] as! AVCaptureDeviceInput
            captureSession.removeInput(currentCameraInput)
            
            
            //Get new input
            var newCamera : AVCaptureDevice!
            
            if currentCameraInput.device.position == AVCaptureDevicePosition.back {
                newCamera = self.cameraWithPosition(.front)
                // Check if camera flash is supported
                newCamera.hasFlash
                if !newCamera.hasFlash && !newCamera.hasTorch {
                    flashButtonItem?.image = UIImage(named: "flashNoneButton")
                    flashButtonItem?.isEnabled = false
                }
            } else {
                newCamera = self.cameraWithPosition(.back)
                // Check if camera flash is supported
                if newCamera!.hasFlash || newCamera!.hasTorch {
                    flashButtonItem?.image = currFlashImage
                    flashButtonItem?.isEnabled = true
                }
            }
            
            //Add input to session
            
            let newVideoInput = try? AVCaptureDeviceInput(device: newCamera)
            captureSession.addInput(newVideoInput)
            
            //Commit all the configuration changes at once
            captureSession.commitConfiguration()
        }
    }
    
    // Cropper bottom bar
    @IBAction func retakeButtonPressed(_ sender: AnyObject) {
        cropVC.removeFromParentViewController()
        cropVC.view.removeFromSuperview()
        
        captureButtonsView.isHidden = false
        cameraPreviewView.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationItem.leftBarButtonItem = self.flashButtonItem
            
            self.reviewAndCrop.center.x = self.reviewAndCrop.center.x + self.screenSize.width
            self.captureAColor.center.x = self.view.center.x
            
            self.cropButtonsView.alpha = 0
            self.captureButtonsView.alpha = 1
            if self.cameraAccessView.isHidden == false {
                self.cameraAccessView.alpha = 1
            }
            
            if let _ = self.captureDevice {
                if let previewLayer = self.previewLayer {
                    self.captureButton.isUserInteractionEnabled = true
                    previewLayer.connection.isEnabled = true
                }
            }
            
            self.view.layoutIfNeeded()
            
        }, completion: { (completed) in
//            self.captureSession.startRunning()
            self.cropButtonsView.isHidden = true
        }) 
    }
    
    @IBAction func rotateButtonPressed(_ sender: AnyObject) {
        cropVC.rotateCropViewClockwise()
    }
    
    @IBAction func looksGreatButtonPressed(_ sender: AnyObject) {
        //Continue to next screen
        cropVC.doneButtonTapped()
    }
    
    // MARK: - Helper functions
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(_ position : AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        for device in devices {
            if (device.position == position) {
                return device;
            }
        }
        return nil
    }
    
    func updateFlashButtonImage() {
        guard let captureDevice = captureDevice, captureDevice.hasFlash && captureDevice.hasTorch else {
            return
        }
        
        if captureDevice.flashMode == AVCaptureFlashMode.off {
            currFlashImage = UIImage(named: "flashOffButton")
            flashButtonItem?.tintColor = UIColor.white
        } else {
            currFlashImage = UIImage(named: "flashButton")
            flashButtonItem?.tintColor = UIColor(hex: 0xffb660)
        }
        
        flashButtonItem?.image = currFlashImage
    }
    
    func beginSession() {
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch {
            
        }
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = CGRect(x: 0, y: 0, width: imageView.width, height: imageView.height)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.imageView.alpha = 0
        self.cameraPreviewView.layer.insertSublayer(previewLayer!, at: 1)
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        captureSession.startRunning()
    }
    
    fileprivate func getVideoConnection(_ stillOutput : AVCaptureStillImageOutput) -> AVCaptureConnection? {
        var videoConnection : AVCaptureConnection?
        for connecton in stillOutput.connections {
            //find a matching input port
            for port in (connecton as AnyObject).inputPorts!{
                if (port as AnyObject).mediaType == AVMediaTypeVideo {
                    videoConnection = connecton as? AVCaptureConnection
                    break //for port
                }
            }
            if videoConnection  != nil {
                break // for connections
            }
        }
        return videoConnection
    }
    
    fileprivate func captureImage(_ imageSampleBuffer: CMSampleBuffer) {
        let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
        pickedImage = UIImage(data: imageDataJpeg!)!
//        captureSession.stopRunning()
        previewLayer?.connection.isEnabled = false
        
        showCropper(pickedImage!)
    }
    
    func showCropper(_ pickedImage : UIImage) {
        print("pickedImage: \(pickedImage)")
        // Camera preview + image to be cropped
        cropVC = TOCropViewController(image: pickedImage)
        
        cropVC.cropView.cropBoxResizeEnabled = false
        cropVC.cropView.aspectRatio = CGSize(width: 1, height: 1)
        cropVC.cropView.aspectRatioLockEnabled = true
        cropVC.cropView.gridOverlayView.displayVerticalGridLines = false
        cropVC.cropView.gridOverlayView.displayHorizontalGridLines = false
        
        cropVC.toolbar.isHidden = true
        cropVC.delegate = self
        cropVC.view.frame = CGRect(x: 0, y: 0, width: imageView.width, height: imageView.height)
        cropVC.view.backgroundColor = UIColor.clear
        cropVC.cropView.backgroundColor = UIColor.clear
        
        imageView.subviews.forEach {$0.removeFromSuperview()}
        imageView.addSubview(cropVC.view)
        
        // Bottom bar
        cropButtonsView.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            // Navigation bar and top bar
            self.navigationItem.leftBarButtonItem = self.backButtonItem
            self.reviewAndCrop.center.x = self.view.center.x
            self.captureAColor.center.x = self.captureAColor.center.x - self.screenSize.width
            
            // Camera preview + image to be cropped
            self.cameraPreviewView.alpha = 0
            self.imageView.alpha = 1
            if self.cameraAccessView.isHidden == false {
                self.cameraAccessView.alpha = 0
            }
            
            // Bottom bar
            self.captureButtonsView.alpha = 0
            self.cropButtonsView.alpha = 1
            
        }, completion: { (completion) in
            self.captureButtonsView.isHidden = true
        }) 
    }
}

// MARK:- UINavigationControllerDelegate
extension CameraOverlayVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController.navigationBar.barTintColor = UIColor.shelfPink()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CameraOverlayVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            captureSession.stopRunning()
            showCropper(pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker = UIImagePickerController()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TOCropViewControllerDelegate
extension CameraOverlayVC: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController!, didCropTo image: UIImage!, with cropRect: CGRect, angle: Int) {
        pickedImage = image;
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateShelfie", bundle: nil)
        let vc: SelectBrandVC = storyboard.instantiateViewController(withIdentifier: "SelectBrandVC") as! SelectBrandVC
        let color = SColor()
        color.image = pickedImage
        
        vc.color = color
        navigationController?.pushViewController(vc, animated: true)
    }
}
