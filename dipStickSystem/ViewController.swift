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
    
    var image: UIImage?

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet var paletteViews: [UIView]!
    @IBOutlet var paletteLabels: [UILabel]!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getImage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImage(){
        
        guard let testimage = image else { return }//使用從CameraVC傳來的圖
        imageView.image = testimage

        DispatchQueue.global(qos: .default).async {
            
            guard let colors = ColorThief.getPalette(from: testimage, colorCount: 10, quality: 1, ignoreWhite: true) else {
                return
            }
            
            let start = Date()
            
            guard let dominantColor = ColorThief.getColor(from: testimage) else {
                return
            }
            
            let elapsed = -start.timeIntervalSinceNow
            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
            
            DispatchQueue.main.async { [weak self] in
                for i in 0 ..< 9 {
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
                let convertResult = self?.convertInt8ToInt(color: dominantColor)
                self?.resultLabel.text = self?.getResult(numberR: convertResult!.0, numberG: convertResult!.1, numberB: convertResult!.2)
            }
        }
   }
    
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
//
//        picker.dismiss(animated: true, completion: nil)
//        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
//        imageView.image = image
//
//        DispatchQueue.global(qos: .default).async {
//            guard let colors = ColorThief.getPalette(from: image, colorCount: 10, quality: 10, ignoreWhite: true) else {
//                return
//            }
//            let start = Date()
//            guard let dominantColor = ColorThief.getColor(from: image) else {
//                return
//            }
//            let elapsed = -start.timeIntervalSinceNow
//            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
//            DispatchQueue.main.async { [weak self] in
//                for i in 0 ..< 9 {
//                    if i < colors.count {
//                        let color = colors[i]
//                        self?.paletteViews[i].backgroundColor = color.makeUIColor()
//                        self?.paletteLabels[i].text = "getPalette[\(i)] R\(color.r) G\(color.g) B\(color.b)"
//                    } else {
//                        self?.paletteViews[i].backgroundColor = UIColor.white
//                        self?.paletteLabels[i].text = "-"
//                    }
//                }
//                self?.colorView.backgroundColor = dominantColor.makeUIColor()
//                self?.colorLabel.text = "getColor R\(dominantColor.r) G\(dominantColor.g) B\(dominantColor.b)"
//
//            }
//        }
//    }
    
    func convertInt8ToInt(color: MMCQ.Color?) -> (newNumberR:Int, newnumberG:Int, newnumberB:Int){
        
        let numberR :String
        let numberG :String
        let numberB :String
        
        let numberRI :Int
        let numberGI :Int
        let numberBI :Int
        
        func check(numberRI:Int?, numberGI:Int?, numberBI:Int?) -> (newNumberR:Int, newnumberG:Int, newnumberB:Int){
            guard let newNumberR = numberRI, let newNumberG = numberGI, let newNumberB = numberBI else{
                print("包含空值！")
                return(0,0,0)
            }
            return(newNumberR,newNumberG, newNumberB)
        }
        
        if let Color = color{
            numberR = "\(Color.r)"
            numberG = "\(Color.g)"
            numberB = "\(Color.b)"
            
            print(numberR+" "+numberG+" "+numberB)
            let checkResult = check(numberRI: Int(numberR) , numberGI: Int(numberG), numberBI: Int(numberB))
            numberRI = checkResult.0
            numberGI = checkResult.1
            numberBI = checkResult.2
            
            return (numberRI,numberGI,numberBI)
        }
        return (0, 0, 0)
    }
    
    func getResult(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        //黃光下（明亮）
//        if ((testR > 228 && testR < 244) && (testG > 164 && testG < 180) && (testB > 140 && testB < 160)){
//            return "1"
//        }else if ((testR > 220 && testR < 236) && (testG > 124 && testG < 140) && (testB > 132 && testB < 152)){
//            return "2"
//        }else if ((testR > 172 && testR < 222) && (testG > 76 && testG < 126) && (testB > 98 && testB < 146)){
//            return "3"
//        }else if ((testR > 118 && testR < 164) && (testG > 52 && testG < 98) && (testB > 76 && testB < 123)){
//            return "4"
//        }else if ((testR > 108 && testR < 116) && (testG > 60 && testG < 68) && (testB > 76 && testB < 92)){
//            return "5"
//        }else{
//            return "error"
//        }
        
//        //座位上（相對較暗）
//        if ((testR > 140 && testR < 171) && (testG > 76 && testG < 113) && (testB > 59 && testB < 84)){
//            return "1"
//        }else if ((testR > 123 && testR < 175) && (testG > 51 && testG < 100) && (testB > 53 && testB < 100)){
//            return "2"
//        }else if ((testR > 113 && testR < 165) && (testG > 43 && testG < 88) && (testB > 56 && testB < 99)){
//            return "3"
//        }else if ((testR > 83 && testR < 101) && (testG > 43 && testG < 60) && (testB > 52 && testB < 68)){
//            return "4"
//        }else if ((testR > 52 && testR < 72) && (testG > 28 && testG < 44) && (testB > 33 && testB < 44)){
//            return "5"
//        }else{
//            return "error"
//        }
        
        //由R->G->B依序探討
        if (testR < 92){
            if(testR >= 83 && testR <= 92){
                if(testG >= 52) && (testB >= 64){
                    return "4"
                }else{
                    return "5"
                }
            }
        }else if (testR >= 92 && testR <= 133){
            if(testR <= 125){
                if((testG >= 34 && testG <= 65) && (testB >= 45 && testB <= 80)){
                    return "4"
                }else{
                    return "5"
                }
            }else {
                if((testG >= 44 && testG <= 76) && (testB >= 60 && testB <= 87)){
                return "3"
                }
            }
        }else if (testR >= 133 && testR <= 172){
            if(testR <= 156){
                if((testG >= 44 && testG <= 83) && (testB >= 60 && testB <= 84)){
                    return "3"
                }
            }else{
                if((testG >= 83 && testG <= 92) && (testB >= 84 && testB <= 101)){
                    return "2"
                }else{
                    return "3"
                }
            }
        }else if (testR >= 172 && testR <= 205){
            if(testR <= 163){
                if((testG >= 83 && testG <= 106) && (testB >= 84 && testB <= 88)){
                    return "2"
                }
            }else{
                if((testG >= 106 && testG <= 110) && (testB >= 88 && testB <= 110)){
                return "1"
                }else{
                    return "2"
                }
            }
        }else{
            return "1"
        }
        
        return "error"
    }
}
//
//fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
//    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
//}
//
//fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
//    return input.rawValue
//}
