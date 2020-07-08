//
//  CameraVC.swift
//  dipStickSystem
//
//  Created by 旌榮 凌 on 2020/6/16.
//  Copyright © 2020 旌榮 凌. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

extension UIImageView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var cameraActionView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
     @IBOutlet weak var countLabel: UILabel!
    
    var croppedImageView = UIImageView()
    var cropImageRect = CGRect()
    var cropImageRectCorner = UIRectCorner()
    var ParentSegmentIndex = 0
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
   
    
    var testingFrequency: Int = 10
    var testingCount: Int = 0
    var colorObjects = [colorTest]()
    var ColorResult = [(Int,Int,Int)](repeating: (0,0,0), count: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput.isHighResolutionCaptureEnabled = true
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupCameraPreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    
    func setupCameraPreview() {
        
        let imageView = setupGuideLineArea()
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(imageView)
        cropImageRect = imageView.frame
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    func setupGuideLineArea() -> UIImageView {
        
        let edgeInsets:UIEdgeInsets = UIEdgeInsets.init(top: 22, left: 22, bottom: 22, right: 22)
        
        let resizableImage = (UIImage(named: "guideImage")?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch))!
        let imageSize = CGSize(width: 30, height: 30)//決定瞄準框的長寬高
        //cropImageRectCorner = [.allCorners]
        
        let imageView = UIImageView(image: resizableImage)
        imageView.frame.size = imageSize
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY);
        return imageView
    }
    
    func previewViewLayerMode(image: UIImage?, isCameraMode: Bool) {
               if isCameraMode {
                   self.captureSession.startRunning()
                   
                   cameraActionView.isHidden = false
                   
                   previewView.isHidden = false
                   capturedImageView.isHidden = true
               } else {
                   self.captureSession.stopRunning()
                   cameraActionView.isHidden = false//決定拍攝後是否隱藏攝影按鈕
                   
                   previewView.isHidden = true
                   capturedImageView.isHidden = false
        
                   // Crop guide Image
                   croppedImageView = UIImageView(image: image!)
                   croppedImageView.center = CGPoint(x:capturedImageView.frame.width/2, y:capturedImageView.frame.height/2)
                   croppedImageView.frame = cropImageRect
                   //croppedImageView.roundCorners2(cropImageRectCorner, radius: 10)
                   capturedImageView.addSubview(croppedImageView)
                   
                   let colorObject = colorTest(image: croppedImageView.image!)
                   
               
                   colorObjects.append(colorObject)
                   //self.cropedImageViews[self.testingCount].image = self.croppedImageView.image! //將擷取的畫面呈現在imageView
                   testingCount += 1
                
                self.countLabel.text = "\(testingCount)"
                   
                   print("已完成\(testingCount)次")
                   
               if(testingCount == testingFrequency){
                       print("本試紙辨識已全部完成！")
                
                ColorResult[0] = getColor(colorObjects: colorObjects)
                ColorResult[1] = getAverageAllColor(colorObjects: colorObjects)
                ColorResult[2] = getMiddleColor(colorObjects: colorObjects)
                ColorResult[3] = getLighterColor(colorObjects: colorObjects)
                ColorResult[4] = getDarkerColor(colorObjects: colorObjects)
                   
                let VC = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
                
                VC.colorResult = ColorResult
                
                self.navigationController?.pushViewController(VC, animated: true)//puch to ViewController
                   
                cleanResult()
                
                   }
               
                   previewViewLayerMode(image: nil, isCameraMode: true)

               }
    }
    
    func getColor(colorObjects:[colorTest]) -> (Int,Int,Int){
        
        var totalR = 0
        var totalG = 0
        var totalB = 0
        
        for i in 0..<colorObjects.count{
            totalR += colorObjects[i].dominateColor.0
            totalG += colorObjects[i].dominateColor.1
            totalB += colorObjects[i].dominateColor.2
        }
        
        return (totalR/10,totalG/10,totalB/10)
    }
    
    func getAverageAllColor(colorObjects:[colorTest]) -> (Int,Int,Int){
        var totalR = 0
        var totalG = 0
        var totalB = 0
        
        for i in 0..<colorObjects.count{
            totalR += colorObjects[i].AverageAllColor.0
            totalG += colorObjects[i].AverageAllColor.1
            totalB += colorObjects[i].AverageAllColor.2
        }
        
        return (totalR/10,totalG/10,totalB/10)
    }
    
    func getMiddleColor(colorObjects:[colorTest]) -> (Int,Int,Int){
        var totalR = 0
        var totalG = 0
        var totalB = 0
        
        for i in 0..<colorObjects.count{
            totalR += colorObjects[i].AverageMiddleColor.0
            totalG += colorObjects[i].AverageMiddleColor.1
            totalB += colorObjects[i].AverageMiddleColor.2
        }
        
        return (totalR/10,totalG/10,totalB/10)
    }
    
    func getLighterColor(colorObjects:[colorTest]) -> (Int,Int,Int){
        var totalR = 0
        var totalG = 0
        var totalB = 0
        
        for i in 0..<colorObjects.count{
            totalR += colorObjects[i].AverageLighterColor.0
            totalG += colorObjects[i].AverageLighterColor.1
            totalB += colorObjects[i].AverageLighterColor.2
        }
        
        return (totalR/10,totalG/10,totalB/10)
    }
    
    func getDarkerColor(colorObjects:[colorTest]) -> (Int,Int,Int){
        var totalR = 0
        var totalG = 0
        var totalB = 0
        
        for i in 0..<colorObjects.count{
            totalR += colorObjects[i].AverageDarkerColor.0
            totalG += colorObjects[i].AverageDarkerColor.1
            totalB += colorObjects[i].AverageDarkerColor.2
        }
        
        return (totalR/10,totalG/10,totalB/10)
    }
    
    func cleanResult() {
        testingCount = 0
        self.countLabel.text = "0"
        colorObjects.removeAll()
//        for i in 0...14{
//        cropedImageViews[i].image = nil//辨識結束清除ImageView中的圖片
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        // Check if the pixel buffer could be converted to image data
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }
        
        let orgImage : UIImage = UIImage(data: imageData)!
        capturedImageView.image = orgImage
        let originalSize: CGSize
        let visibleLayerFrame = cropImageRect
        
        // Calculate the fractional size that is shown in the preview
        let metaRect = (videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame )) ?? CGRect.zero
        
        if (orgImage.imageOrientation == UIImage.Orientation.left || orgImage.imageOrientation == UIImage.Orientation.right) {
            originalSize = CGSize(width: orgImage.size.height, height: orgImage.size.width)
        } else {
            originalSize = orgImage.size
        }
        let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height).integral
        
        if let finalCgImage = orgImage.cgImage?.cropping(to: cropRect) {
            let image = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: orgImage.imageOrientation)
            previewViewLayerMode(image: image, isCameraMode: false)
        }
    }
    
    // MARK: - @IBAction
    @IBAction func actionCameraCapture(_ sender: AnyObject) {
        
        var photoSettings: AVCapturePhotoSettings
                
        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
//    @IBAction func savePhotoPressed(_ sender: Any) {
//
//        let VC = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
//
//        VC.image = croppedImageView.image!
//        VC.segmentIndex = ParentSegmentIndex
//
//        self.navigationController?.pushViewController(VC, animated: true)//puch to ViewController
//
//        //        UIImageWriteToSavedPhotosAlbum(croppedImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil) //目前沒用到儲存功能
//    }
    @IBAction func mySegmentControl(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            ParentSegmentIndex = 0
        }else{
            ParentSegmentIndex = 1
        }
    }
    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//
//            let alertController = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
//                self.previewViewLayerMode(image: nil, isCameraMode: true)
//            }))
//            present(alertController, animated: true)
//        } else {
//            let alertController = UIAlertController(title: "Saved", message: "Captured guided image saved successfully.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
//                self.previewViewLayerMode(image: nil, isCameraMode: true)
//            }))
//            present(alertController, animated: true)
//        }
//    } //目前沒用到儲存功能
    
    @IBAction func cancelPhotoPressed(_ sender: Any) {
        
        previewViewLayerMode(image: nil, isCameraMode: true)
    }

}
