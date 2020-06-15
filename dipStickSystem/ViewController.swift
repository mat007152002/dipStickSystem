//
//  ViewController.swift
//  dipStickSystem
//
//  Created by 旌榮 凌 on 2020/6/15.
//  Copyright © 2020 旌榮 凌. All rights reserved.
//

import UIKit
import ColorThiefSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet var paletteViews: [UIView]!
    @IBOutlet var paletteLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .photoLibrary
//        present(picker, animated: true, completion: nil)
        getImage()
    }
    
    func getImage(){
        let testimage = UIImage(named: "testPic")//到時候要改寫成從相機取得色塊

        DispatchQueue.global(qos: .default).async {
            guard let colors = ColorThief.getPalette(from: testimage!/*image*/, colorCount: 7, quality: 10, ignoreWhite: true) else {
                return
            }
            let start = Date()
            guard let dominantColor = ColorThief.getColor(from: testimage!/*image*/) else {
                return
            }
            let elapsed = -start.timeIntervalSinceNow
            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
            DispatchQueue.main.async { [weak self] in
                for i in 0 ..< 6 {
                    if i < colors.count {
                        let color = colors[i]
                        self?.paletteViews[i].backgroundColor = color.makeUIColor()
                        self?.paletteLabels[i].text = "getPalette[\(i)] R\(color.r) G\(color.g) B\(color.b)"
                    } else {
                        self?.paletteViews[i].backgroundColor = UIColor.white
                        self?.paletteLabels[i].text = "-"
                    }
                }
                self?.colorView.backgroundColor = dominantColor.makeUIColor()
                self?.colorLabel.text = "getColor R\(dominantColor.r) G\(dominantColor.g) B\(dominantColor.b)"
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
        imageView.image = image
    
        let testimage = UIImage(named: "testPic")

        DispatchQueue.global(qos: .default).async {
            guard let colors = ColorThief.getPalette(from: testimage!/*image*/, colorCount: 7, quality: 10, ignoreWhite: true) else {
                return
            }
            let start = Date()
            guard let dominantColor = ColorThief.getColor(from: testimage!/*image*/) else {
                return
            }
            let elapsed = -start.timeIntervalSinceNow
            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
            DispatchQueue.main.async { [weak self] in
                for i in 0 ..< 6 {
                    if i < colors.count {
                        let color = colors[i]
                        self?.paletteViews[i].backgroundColor = color.makeUIColor()
                        self?.paletteLabels[i].text = "getPalette[\(i)] R\(color.r) G\(color.g) B\(color.b)"
                    } else {
                        self?.paletteViews[i].backgroundColor = UIColor.white
                        self?.paletteLabels[i].text = "-"
                    }
                }
                self?.colorView.backgroundColor = dominantColor.makeUIColor()
                self?.colorLabel.text = "getColor R\(dominantColor.r) G\(dominantColor.g) B\(dominantColor.b)"
            }
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
