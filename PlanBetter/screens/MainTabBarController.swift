//
//  MainTabBarController.swift
//  PlanBetter
//
//  Created by wflower on 17/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.tabBar.items?[0].image = makeThumbnailFromText(text: "Count Down")
//        self.tabBar.items?[0].title = nil
        
//        self.tabBar.items?[0].image = UIImage(named: "countdown.png")
        
//        self.tabBar.items?[1].image = makeThumbnailFromText(text: "To-Do")
//        self.tabBar.items?[1].title = nil
//        
//        self.tabBar.items?[2].image = makeThumbnailFromText(text: "Guests")
//        self.tabBar.items?[2].title = nil
        
//        self.tabBar.items?[2].image = makeThumbnailFromText(text: "Expenses")
//        self.tabBar.items?[2].title = nil
//        
//        self.tabBar.items?[3].image = makeThumbnailFromText(text: "Count Down")
//        self.tabBar.items?[3].title = nil
    }
    

    func makeThumbnailFromText(text: String) -> UIImage {
        // some variables that control the size of the image we create, what font to use, etc.
        
        struct LineOfText {
            var string: String
            var size: CGSize
        }
        
        let imageSize = CGSize(width: 100, height: 60)
        let fontSize: CGFloat = 13.0
        let fontName = "HelveticaNeue"
        let font = UIFont(name: fontName, size: fontSize)!
        let lineSpacing = fontSize * 1.2
        
        // set up the context and the font
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let attributes = [NSAttributedString.Key.font: font]
        
        // some variables we use for figuring out the words in the string and how to arrange them on lines of text
        
        let words = text.components(separatedBy: " ")
        var lines = [LineOfText]()
        var lineThusFar: LineOfText?
        
        // let's figure out the lines by examining the size of the rendered text and seeing whether it fits or not and
        // figure out where we should break our lines (as well as using that to figure out how to center the text)
        
        for word in words {
            let currentLine = lineThusFar?.string == nil ? word : "\(lineThusFar!.string) \(word)"
            let size = currentLine.size(withAttributes: attributes)
            if size.width > imageSize.width && lineThusFar != nil {
                lines.append(lineThusFar!)
                lineThusFar = LineOfText(string: word, size: word.size(withAttributes: attributes))
            } else {
                lineThusFar = LineOfText(string: currentLine, size: size)
            }
        }
        if lineThusFar != nil { lines.append(lineThusFar!) }
        
        // now write the lines of text we figured out above
        
        let totalSize = CGFloat(lines.count - 1) * lineSpacing + fontSize
        let topMargin = (imageSize.height - totalSize) / 2.0
        
        for (index, line) in lines.enumerated() {
            let x = (imageSize.width - line.size.width) / 2.0
            let y = topMargin + CGFloat(index) * lineSpacing
            line.string.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

}
