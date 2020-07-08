//
//  colorTest.swift
//  dipStickSystem
//
//  Created by 旌榮 凌 on 2020/7/6.
//  Copyright © 2020 旌榮 凌. All rights reserved.
//

import Foundation
import ColorThiefSwift

class colorTest {
    let image: UIImage
    
    init(image: UIImage){
        self.image = image
    }
    
    //分析邏輯:
    //1.由相機捕捉的照片以及拍攝前便已決定之分析邏輯建立物件
    //2.物件中還包含colorInt與result屬性，各別的說明如下：
    // (1)ColorInt: 透過ColorThief取得Image之Palette陣列（9個MMCQ.Color物件），透過getAverageFiveColor方法，從MMCQ.Color物件陣列中排除最暗與最亮各兩個顏色，取得五個顏色的平均值並回傳(Int,Int,Int)
    // (2)result: 透過chooseLogic方法，將顏色用對應的方法取得分析結果，回傳結果String
    // (3)單項測試的subLogic永遠為-1，多項測試根據第幾項編號
     
    var dominateColor : (Int,Int,Int) {
        
        let dominateColor = ColorThief.getColor(from: image)
        let dominateColorInt = convertInt8ToInt(color: dominateColor)
        return dominateColorInt
        
    }
    
    var colorPalette : [MMCQ.Color] {
        let colors = ColorThief.getPalette(from: image, colorCount: 10, quality: 1, ignoreWhite: true)
        var colorsCheck = [MMCQ.Color]()
        
        if colors != nil{
            colorsCheck = colors!
        }
        
        return colorsCheck
    }
    
    var AverageAllColor: (Int,Int,Int) {
        
        return getAverageColor(colors: colorPalette, method: 4)//method 4 = 九個顏色平均
        
    }
    
    var AverageMiddleColor: (Int, Int, Int) {
        
        return getAverageColor(colors: colorPalette, method: 1)//method 1 = 取中間五個: 尿酸
    
    }
    
    var AverageLighterColor: (Int, Int, Int) {

        return getAverageColor(colors: colorPalette, method: 2)//method 2 = 取後五個（五個最亮的):陰道pH
            
    }
    
    var AverageDarkerColor: (Int, Int, Int) {
        
        return getAverageColor(colors: colorPalette, method: 3)//method 2 = 取前五個（五個最亮的):陰道pH
        
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
    
    func getAverageColor(colors:[MMCQ.Color]?, method:Int ) -> (NumberR:Int, NumberG:Int, NumberB:Int) {
        
        var colorsInt = [(Int,Int,Int)](repeating: (0,0,0), count: 9)//紀錄從Int8轉成Int的RGB值
        var colorsIntSum = [Int](repeating: 0, count: 9)//[0,0,0,0,0,0,0,0,0] //透過把RGB加總判斷哪個顏色最亮
        var chosenColor = [(Int,Int,Int)](repeating: (0,0,0), count: 5)//紀錄選擇的中間五色
        var chosenIndex = [Int](repeating: 0, count: 5)
        var averageColor = [Int](repeating: 0, count: 3)//[0, 0, 0] 紀錄加總的RGB值
        
        if let colorsCheck = colors {
            for i in 0 ..< colorsCheck.count {
                colorsInt[i] = convertInt8ToInt(color: colorsCheck[i])
                colorsIntSum[i] = colorsInt[i].0 + colorsInt[i].1 + colorsInt[i].2
            }
        }
        
        let colorsIntSumSorted = colorsIntSum.sorted()
        //從暗到亮排好的9個顏色總和＆還沒排的9個顏色總和
        
        if(method == 4){
            for i in 0 ..< 9 {
                       averageColor[0] = averageColor[0] + colorsInt[i].0
                       averageColor[1] = averageColor[1] + colorsInt[i].1
                       averageColor[2] = averageColor[2] + colorsInt[i].2
                   }
                   
                   let resultR = averageColor[0]/colorsInt.count
                   let resultG = averageColor[1]/colorsInt.count
                   let resultB = averageColor[2]/colorsInt.count
                   
                   return (resultR, resultG, resultB)
        }else{
            
            let StartingPoint : Int
            
            if(method == 1){
                StartingPoint = 2 //因為去掉頭尾兩個顏色，故第一個顏色從2開始(2,3,4,5,6)
            }else if (method == 2){
                StartingPoint = 4 //因為去掉頭的四個顏色，故第一個顏色從4開始(4,5,6,7,8)
            }else{//method 3
                StartingPoint = 0 //因為選擇前四個顏色，故第一個顏色從0開始(0,1,2,3,4)
            }
            
            for i in 0...4 {
                chosenIndex[i] = colorsIntSum.firstIndex(of: colorsIntSumSorted[i+StartingPoint])! //chosenIndex代表回colorsIntSum裡找排完順序顏色的位置，位置從i+StartingPoint開始
                chosenColor[i] = colorsInt[chosenIndex[i]] //挑出所需的五個顏色
                
                averageColor[0] = averageColor[0] + chosenColor[i].0 //依序把五個顏色的RGB加總
                averageColor[1] = averageColor[1] + chosenColor[i].1
                averageColor[2] = averageColor[2] + chosenColor[i].2
            }
            
            let resultR = averageColor[0]/chosenColor.count //計算平均
            let resultG = averageColor[1]/chosenColor.count
            let resultB = averageColor[2]/chosenColor.count
            
            return (resultR, resultG, resultB)
        }
    }
    
}
