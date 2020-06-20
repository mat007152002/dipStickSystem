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
    @IBOutlet weak var averageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getImage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chooseLogic(logic:Int, NumberR:Int, NumberG:Int, NumberB:Int) -> String { //根據環境選擇Light(預設)或Dark
           switch logic {
           case 0:
               return getAverageResult2(numberR: NumberR, numberG: NumberG, numberB: NumberB)
           case 1:
               return getAverageResult3(numberR: NumberR, numberG: NumberG, numberB: NumberB)
           default:
               return getLightResult(numberR: NumberR, numberG: NumberG, numberB: NumberB)
           }
       }
    
    func getImage(){ //將圖片的RGB組成分析出來
        
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
                //let convertResult = self?.convertInt8ToInt(color: dominantColor)
                let a = self?.getAverageLighterColor(colors: colors)
                let b = self?.getAverageColor(colors: colors)
                self?.averageLabel.text = "get Average R\(b?.0 ?? 0) G\(b?.1 ?? 0) B\(b?.2 ?? 0)"
                self?.resultLabel.text = self?.chooseLogic(logic: self?.segmentIndex ?? 0, NumberR: a!.0, NumberG: a!.1, NumberB: a!.2)
            }
        }
   }
    
    func convertInt8ToInt(color: MMCQ.Color?) -> (newNumberR:Int, newNumberG:Int, newNumberB:Int){
        
        let numberR :String
        let numberG :String
        let numberB :String
        
        let numberRI :Int
        let numberGI :Int
        let numberBI :Int
        
        func check(numberRI:Int?, numberGI:Int?, numberBI:Int?) -> (newNumberR:Int, newNumberG:Int, newNumberB:Int){
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
            
            let checkResult = check(numberRI: Int(numberR) , numberGI: Int(numberG), numberBI: Int(numberB))
            numberRI = checkResult.0
            numberGI = checkResult.1
            numberBI = checkResult.2
            
            return (numberRI,numberGI,numberBI)
        }
        return (0, 0, 0)
    }
    
    func getAverageLighterColor(colors:[MMCQ.Color]?) -> (NumberR:Int, NumberG:Int, NumberB:Int) {
        
        var colorsInt = [(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0)]
        var colorsIntSum = [0,0,0,0,0,0,0,0,0]
        var chosenColor = [(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0)]
        var averageColor = [0, 0, 0]
        
        for i in 0 ..< 9 {
            colorsInt[i] = convertInt8ToInt(color: colors?[i])
            colorsIntSum[i] = colorsInt[i].0 + colorsInt[i].1 + colorsInt[i].2
            
        }
        
        let colorsIntSumSorted = colorsIntSum.sorted()
        //排好的9個顏色總和＆還沒排的9個顏色總和
        
        let indexOf1 = colorsIntSum.firstIndex(of: colorsIntSumSorted[2])
        let indexOf2 = colorsIntSum.firstIndex(of: colorsIntSumSorted[3])
        let indexOf3 = colorsIntSum.firstIndex(of: colorsIntSumSorted[4])
        let indexOf4 = colorsIntSum.firstIndex(of: colorsIntSumSorted[5])
        let indexOf5 = colorsIntSum.firstIndex(of: colorsIntSumSorted[6])
        
        chosenColor[0] = colorsInt[indexOf1!]
        print(chosenColor[0])
        chosenColor[1] = colorsInt[indexOf2!]
        print(chosenColor[1])
        chosenColor[2] = colorsInt[indexOf3!]
        print(chosenColor[2])
        chosenColor[3] = colorsInt[indexOf4!]
        print(chosenColor[3])
        chosenColor[4] = colorsInt[indexOf5!]
        print(chosenColor[4])
        
        for i in 0 ..< 5 {
            averageColor[0] = averageColor[0] + chosenColor[i].0
            averageColor[1] = averageColor[1] + chosenColor[i].1
            averageColor[2] = averageColor[2] + chosenColor[i].2
        }
        
        let resultR = averageColor[0]/chosenColor.count
        let resultG = averageColor[1]/chosenColor.count
        let resultB = averageColor[2]/chosenColor.count
        
        print("\(resultR)"+" "+"\(resultG)"+" "+"\(resultB)")
        
        return (resultR, resultG, resultB)
    }
    
    func getAverageColor(colors:[MMCQ.Color]?) -> (NumberR:Int, NumberG:Int, NumberB:Int) {
        
        var colorsInt = [(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0)]
        var averageColor = [0, 0, 0]
        
        for i in 0 ..< 9 {
            colorsInt[i] = convertInt8ToInt(color: colors?[i])
            averageColor[0] = averageColor[0] + colorsInt[i].0
            averageColor[1] = averageColor[1] + colorsInt[i].1
            averageColor[2] = averageColor[2] + colorsInt[i].2
        }
        
        let resultR = averageColor[0]/colorsInt.count
        let resultG = averageColor[1]/colorsInt.count
        let resultB = averageColor[2]/colorsInt.count
        
        return (resultR, resultG, resultB)
    }
    
    func getAverageResult3(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        if (testR <= 141){
            //可能是4V5
            if(testR < 115){
                return "5"
            }else{
                //用TestG看是4V5
                if (testG < 56){
                    return "5"
                }else if (testG >= 56 && testG <= 61){
                    //可能是4V5
                    if(testB < 90){
                        return "4"
                    }else{
                        return "5"
                    }
                }else{ //大於60
                    return "5"
                }
            }
        }else if (testR > 141 && testR <= 178){
            //可能是3V4
            if (testR < 158){
                return "4"
            }else{
                //可能是3V4
                if (testG < 74){
                    return "4"
                }else if (testG >= 74 && testG <= 93){
                    if (testB < 110){
                        return "3"
                    }else{
                        return "4"
                    }
                }else { //大於93
                    return "3"
                }
            }
        }else if (testR > 178 && testR < 191){
            //可能是2V3
            if (testR < 182){
                return "3"
            }else{
                //可能是2V3
                if (testG < 86){
                    return "3"
                }else if (testR >= 86 && testR <= 89){
                    //可能是2V3
                    if (testB < 101){
                        return "2"
                    }else {
                        return "3"
                    }
                }else{
                    return "2"
                }
            }
        }else{ // 大於191
            //可能是1V2
            if (testR < 198){
                return "2"
            }else if (testR >= 198 && testR <= 214){
                if (testG < 130){
                    return "2"
                }else if(testG >= 130 && testG <= 140){
                    if (testB < 136){
                        return "1"
                    }else{
                        return "2"
                    }
                }else{
                    return "2"
                }
            }else{
                return "1"
            }
        }
    }
    
    func getAverageResult2(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        if (testR <= 103){
            return "5"
        }else if (testR >= 103 && testR <= 141){
            return "4"
        }else if (testR >= 141 && testR <= 185){
            return "3"
        }else if (testR >= 185 && testR <= 206){
            if(testR < 202){
                return "2"
            }else{
                if(testG < 125){
                    return "2"
                }else{
                    return "1"
                }
            }
        }else{
            return "1"
        }
    }
    
    func getAverageResult(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        if (testR <= 108){
            //可能是4V5
            if(testR <= 92){
                return "5"
            }else{//>92
                if(testG < 45){
                    return "5"
                }else if(testG >= 45 && testG <= 60){
                    //可能是4V5，看B
                    if(testB <= 76){
                        return "4"
                    }else{
                        return "5"
                    }
                }else{//大於60
                    return "5"
                }
            }
        }else if (testR > 108 && testR <= 140){
            //可能是3V4
            if(testR < 124){
                return "4"
            }else{ // 124-140
                if (testG < 64) {
                    return "3"
                }else{
                    return "4"
                }
            }
        }else if (testR > 140 && testR <= 196){
            //可能是1V2V3
            if(testR < 146){
                return "3"
            }else if(testR >= 146 && testR <= 176){
                //可能是1V3
                if(testG <= 88){
                    return "3"
                }else if(testG > 88 && testG < 100){
                    if(testB < 80){
                        return "1"
                    }else{
                        return "3"
                    }
                }else{ //大於100
                    return "1"
                }
            }else{//176-196
                //可能是1V2V3
                if(testG > 106){
                    return "1"
                }else if(testG <= 106 && testG > 100){
                    return "3"
                }else if(testG <= 100 && testG > 88 ){
                    //可能是2V3
                    if(testB < 108){
                        return "2"
                    }else{
                        return "3"
                    }
                }else{ //小於88
                    return "3"
                }
            }
        }else{ //大於196
            //可能是1V2
            if (testR > 196 && testR <= 212) {
                //可能是1或2
                if (testG < 140){
                    return "2"
                }else{
                    return "1"
                }
                
            }else{ //大於212
                return "2"
            }
        }
    }
    
    func getLightResult(numberR:Int, numberG:Int, numberB:Int) -> String {
        let testR = numberR
        let testG = numberG
        let testB = numberB
        
        //由R->G->B依序探討
        
        if (testR <= 148){
            if (testR <= 148 && testR >= 115){
                //介於115-133之間的需透過G&B判斷是4或5
                //了解R是115-133時，G的範圍為何
                if (testG < 52){
                    return "4"
                }else if (testG <= 78 && testG >= 52){
                    //可能是4V5
                    if (testB < 111){
                        return "4"
                    }else{
                        return "5"
                    }
                }else{ // >78
                    return "5"
                }
            }else{
                //低於115先判斷是5，再看看需不需要再加入G&B的判斷
                return "5"
            }
        }else if (testR <= 193 && testR > 148){
            //這段可能是3V4V5
            if (testR > 148 && testR < 154){
                return "4"
            }else if (testR >= 154 && testR <= 193){
                if (testG < 60){
                    return "3"
                }else if (testG >= 60 && testG <= 75){
                    //可能是3V4
                    if (testB < 97){
                        return "3"
                    }else{
                        return "4"
                    }
                }else{ //大於75
                    return "4"
                }
            }
        }else if (testR <= 228 && testR >= 193){
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
        }else { // 大於228
            //這段可能是1V2
            if(testG >= 156){
                return "1"
            }else{// <148
                return "2"
            }
        }
        
        return "end"
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
}
