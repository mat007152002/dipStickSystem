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
    var segmentIndex : Int?

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
                self?.resultLabel.text = self?.chooseLogic(logic: self?.segmentIndex ?? 0, NumberR: convertResult!.0, NumberG: convertResult!.1, NumberB: convertResult!.2)
                    //self?.getResultNearLight(numberR: convertResult!.0, numberG: convertResult!.1, numberB: convertResult!.2)
            }
        }
   }
    
    func chooseLogic(logic:Int, NumberR:Int, NumberG:Int, NumberB:Int) -> String {
        switch logic {
        case 0:
            return getLightResult(numberR: NumberR, numberG: NumberG, numberB: NumberB)
        case 1:
            return getDarkResult(numberR: NumberR, numberG: NumberG, numberB: NumberB)
        default:
            return getLightResult(numberR: NumberR, numberG: NumberG, numberB: NumberB)
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
    
    func getDarkResult(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        //由R->G->B依序探討
        
        if (testR <= 108){
            if (testR <= 108 && testR >= 100){
                //介於100-108之間的需透過G&B判斷是4或5
                //了解R是100-108時，G的範圍為何
                if (testG < 52){
                    //是4
                    return "4"
                }else if (testG == 52){
                    //等於52看B吧...
                    if(testB < 71){
                        //是5
                        return "5"
                    }
                    else {
                        //是4
                        return "4"
                    }
                }else {
                    //是5
                    return "5"
                }
            }else{
                //低於100先判斷是5，再看看需不需要再加入G&B的判斷
                return "5"
            }
        }else if (testR <= 132 && testR > 108){
            //目前應當是4，再看看需不需要再加入G&B的判斷
            return "4"
        }else if (testR <= 179 && testR >= 135){
            if (testR <= 148){
                //介於135-148應當是3，再看看需不需要再加入G&B的判斷
                return "3"
            }else { // 149-179，假如R介於148-179之間可能是2，假如介於156-179之間可能是1
                if (testR <= 179 && testR >= 156){
                    //這段可能是1或2或3
                    if (testG > 90){
                        //是1
                        return "1"
                    }else if (testG <= 90 && testG >= 79){
                        //可能是2V3
                        if (testB < 95){
                            return "2"
                        }else{
                            return "3"
                        }
                    }else if (testG <= 79 && testG > 66 ){
                        //是2V3
                        if (testB > 83){
                            return "3"
                        }else{
                            return "2"
                        }
                    }else{
                        return "2"
                    }
                }else if (testR <= 156 && testR >= 149){
                    //這段有可能是2V3，缺3的判斷
                    if (testG < 60){
                        return "2"
                    }else if (testG == 60){
                        if (testB < 76){
                            return "2"
                        }else{
                            return "3"
                        }
                    }else{
                        return "3"
                    }
                }
            }
        }else if (testR <= 215 && testR >= 179){
            //這段可能是1或2
            if (testG < 116){
                //是2
                return "2"
            }else if (testG <= 117 && testG >= 116){
                //可能是1V2，用B判斷
                if(testB < 110){
                    //是2
                    return "1"
                }
                else{
                    //是1
                    return "2"
                }
            }else{
                //大於117是1
                return "1"
            }
        }else if (testR <= 228 && testR >= 215){
            //是1
            return "1"
        }else{
            //error
            return "error"
        }
        return "end"
    }
    
    func getLightResult(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        //由R->G->B依序探討
        
        if (testR <= 133){
            if (testR <= 133 && testR >= 115){
                //介於115-133之間的需透過G&B判斷是4或5
                //了解R是115-133時，G的範圍為何
                if (testG < 52){
                    return "4"
                }else if (testG <= 67 && testG >= 52){
                    //可能是4V5
                    if (testB > 91){
                        return "5"
                    }else{
                        return "4"
                    }
                }else{ // >67
                    return "5"
                }
            }else{
                //低於115先判斷是5，再看看需不需要再加入G&B的判斷
                return "5"
            }
        }else if (testR <= 174 && testR > 133){
            //這段可能是3V4V5
            if (testR > 133 && testR < 154){
                return "4"
            }else if (testR >= 154 && testR <= 174){
                if (testG < 58){
                    return "3"
                }else if (testG >= 58 && testG <= 79){
                    //可能是3V4
                    if (testB < 100){
                        return "3"
                    }else{
                        return "4"
                    }
                }else{ //大於79
                    return "4"
                }
            }
        }else if (testR <= 228 && testR >= 174){
            //這段可能是1V2V3
            if (testR < 200){
                return "3"
            }else if ( testR >= 200 && testR <= 204){
                //可能是1V3
                if (testG <= 92){
                    return "3"
                }else{
                    return "1"
                }
            }else{ //204-228
                //可能是1V2V3
                if (testG < 100) {
                    return "3"
                }else if (testG == 100){
                    //看是2V3
                    if (testB < 120){
                        return "2"
                    }else{
                        return "3"
                    }
                }else if (testG > 100 && testG <= 120){
                    return "2"
                }else {
                    return "1"
                }
            }
        }else if (testR <= 245 && testR >= 228 ){
            //這段可能是1V2
            if (testG < 148){
                return "2"
            }else{
                return "1"
            }
        }else { // 大於245
            //這段是1
            return "1"
        }
        
        return "end"
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
